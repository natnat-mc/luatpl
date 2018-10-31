local tpl, xml=require 'luatpl', 'luaxml'

local template=tpl.parse(io.open 'examples/base.html')

local values={}
values.title="An interesting title"
values.sections={}

table.insert(values.sections, {title="#1"})
table.insert(values.sections, {title="#2", text=[[Finally some good fucking food]]})

print(template:render(values))
