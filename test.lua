#!/usr/local/bin/lua
---------------------------------------------------------------------
-- LuaXPath test file.
---------------------------------------------------------------------

require "xpath"
local lom = require "lxp.lom"

local xmlTest =
[[
<?xml version="1.0" encoding="ISO-8859-1"?>
<root>
	<element id="1" name="element1">text of the first element</element>
        <element id="2" name="element2">
		<subelement>text of the second element</subelement>
        </element>
</root>
]]

-- get all elements
xpath.selectNodes(lom.parse(xmlTest),'//element')
-- get the subelement text
xpath.selectNodes(lom.parse(xmlTest),'/root/element/subelement/text()')
-- get the first element
xpath.selectNodes(lom.parse(xmlTest),'/root/element[@id="1"]')

