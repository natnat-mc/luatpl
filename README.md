# luatpl
A simple template engine in pure Lua

## Installation
- This library depends on [`natnat-mc/luaxml`](https://github.com/natnat-mc/luaxml)
- Clone this repo (`git clone https://github.com/natnat-mc/luaxml.git`) somewhere in your Lua search path

## Loading the library
- The Lua search path should find `?/init.lua` and `?/?.lua` in this order.
- This library should be found in the Lua search path.
- `luaxml` should be available in the Lua search path.

You should load `luatpl` and optionally `luaxml` with `require`. These libraries **do not** create globals.  
Loading `luaxml` can help with the resulting xml tree.
```lua
local tpl=require 'luatpl'
local xml=require 'luaxml'
```

## Usage

### Core functions

#### `tpl.template tpl.parse(string|file template)`
Parses a template from a string or file handle.

### Class: `tpl.template`
This class represents a template.

#### `xml.node template:apply(table? values)`
Creates a xml tree from the template, with optional values.

#### `string template:render(table? values)`
Directly renders a HTML document from the template, with optional values.

#### `tpl.template template:clone()`
Clones a template, resulting in an identical but separate object.

#### `xml.node template.tree`
The internal structure of the template. Modify at your own risk.