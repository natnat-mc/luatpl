--[[ Template lib
	Handles simple templates in pure Lua.
	Templates are XML-based, and require the
	 `natnat-mc/luaxml` lib to be installed as `luaxml` or
	 as `xml` in the Lua search path.
]]
local tpl={}

-- try loading a library
local function tryrequire(lib)
	local a, b=pcall(require, lib)
	if a then
		return b
	else
		return nil, b
	end
end

-- load the XML lib
local xml=tryrequire 'luaxml' or tryrequire 'xml'
if not xml then
	error "Couldn't load the xml library"
end

--[[ class: tpl.template
	Holds a template.
	tree: xml.node
]]
tpl.template={}
tpl.template.__index=tpl.template

--[[ xml.node template:apply(map<string,any>? values)
	Creates a XML tree from this template and optional
	 values.
	If no values are given, an empty table is used instead.
]]
function tpl.template:apply(values)
	if not values then
		values={}
	end
	
	local rootnode=xml.createnode('root')
	
	-- execute template:code blocks
	local function exec(node, output, values)
		local code='return function(node, values, tpl, xml)\n'
		code=code..node:gettext()
		code=code..'\nend'
		local load=loadstring or load
		local block, err=load(code)
		if not block then
			error(err)
		end
		local fn=block()
		return fn(output, values, tpl, xml)
	end
	
	-- load template:template values
	local function getvals(nodes, ovalues)
		local values={}
		for i, node in ipairs(nodes) do
			local t=node.type
			if not t:match '^template:' then
				error "Non-template block in template"
			end
			local ty=t:sub(#("template:")+1)
			local name=node:getproperty 'name'
			if not name then
				error "Template value without name"
			end
			
			if ty=='string' then
				-- string values
				local value=node:getproperty 'value'
				if not value then
					error "String key without value"
				end
				values[name]=value
			elseif ty=='number' then
				-- number values
				local value=node:getproperty 'value'
				if not value then
					error "Number key without value"
				end
				value=tonumber(value)
				if not value then
					error "Invalid number"
				end
				values[name]=value
			elseif ty=='code' then
				-- code return value
				values[name]=exec(node, nil, ovalues)
			elseif ty=='key' then
				-- key from current values
				local orig=node:getproperty 'orig' or name
				if ovalues[name]==nil then
					error "Original value doesn't exist"
				end
				values[name]=ovalues[orig]
			elseif ty=='node' then
				-- XML node
				local c=node.children
				if not c or #c~=1 then
					error "node key has one child"
				end
				values[name]=c[1]
			else
				error("Unknown type "..ty)
			end
		end
		return values
	end
	
	local function imp(node, output, values)
		if node.type:match '^template:' then
			local within=node:getproperty 'within'
			if within then
				values=values[within]
				if type(values)~='table' then
					error "Values is not a table in within"
				end
			end
			local subtype=node.type:sub(#("template:")+1)
			if subtype=='group' or subtype=='then' or
			 subtype=='else' then
				-- group passes everything through
				local children=node.children or {}
				for i, child in ipairs(children) do
					imp(child, output, values)
				end
			elseif subtype=='var' then
				-- var substitutes a variable or node
				local key=node:getproperty 'name'
				if not key then
					error "var tag without name"
				end
				local value=values[key]
				if type(value)=='string' then
					local node=xml.createtextnode(value)
					output:appendchild(node)
				elseif getmetatable(value)==xml.node then
					output:appendchild(value)
				else
					error("No such value: "..key)
				end
			elseif subtype=='foreach' then
				-- foreach loops through its values
				local key=node:getproperty 'name'
				if not key then
					error "foreach tag without name"
				end
				if not node.children then
					error "foreach tag without children"
				end
				if #node.children~=1 then
					error "foreach takes exactly one child"
				end
				local value=values[key]
				if type(value)~='table' then
					error "foreach without a table"
				end
				for i, v in ipairs(value) do
					imp(node.children[1], output, v)
				end
			elseif subtype=='code' then
				-- code gets executed
				exec(node, output, values)
			elseif subtype=='if' then
				-- if need to meet a condition
				local matcher={}
				matcher.parent=(function(a)
					return a==node
				end)
				
				-- find the code block
				matcher.type='template:code'
				local code=node:queryselector({matcher})
				local result
				if code then
					result=exec(code, output, values)
				else
					result=true
				end
				
				-- find the right block
				if result then
					-- find the then block
					matcher.type='template:then'
				else
					-- find the else block
					matcher.type='template:else'
				end
				
				-- evaluate the block
				local bl=node:queryselector({matcher})
				if bl then
					imp(bl, output, values)
				end
			elseif subtype=='template' then
				-- execute a sub-template
				local name=node:getproperty 'name'
				local key=node:getproperty 'values'
				if not name then
					error "Template call without name"
				end
				local vals=key and values[key] or {}
				if key and type(vals)~='table' then
					error "Values are not a table"
				end
				local c=node.children
				if not key and c and #c~=0 then
					vals=getvals(c, values)
				end
				local tpl=values[name]
				if not tpl then
					error "Template call without template"
				end
				
				-- call the template
				local root=tpl:apply(vals)
				
				-- add the returned root to the output
				output:appendchild(root)
			else
				-- unknown type
				error("Unknown subtype: "..subtype)
			end
		else
			local nextv=output:appendchild(node:clone(false))
			for i, child in ipairs(node.children or {}) do
				imp(child, nextv, values)
			end
		end
	end
	
	imp(self.tree, rootnode, values)
	rootnode.children[1].parent=nil
	return rootnode.children[1]
end

--[[ string template:render(map<string,any>? values)
	Renders a template to HTML, with optional values.
	If no values are given, an empty table is used instead.
	This yields the same result as applying the template
	 and then dumping the XML tree as HTML.
]]
function tpl.template:render(values)
	return self:apply(values):dump(true, true)
end

--[[ tpl.template template:clone()
	Clones a template, resulting in an identical but
	 separate object.
]]
function tpl.template:clone()
	local clone=setmetatable({}, tpl.template)
	clone.tree=self.tree:clone(true)
	return clone
end

--[[ tpl.template tpl.parse(string|file template)
	Reads a template from a string or file handle.
]]
function tpl.parse(template)
	if type(template)~='string' then
		template=template:read '*a'
	end
	local templateobj=setmetatable({}, tpl.template)
	templateobj.tree=xml.parse(template, true)
	return templateobj
end

return tpl
