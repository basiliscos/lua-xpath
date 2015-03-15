#!/usr/bin/env lua

require 'Test.More'
require "luaxpath"
require "luaxpath.datadumper"
local lom = require "lxp.lom"

-- there is need of that function to see what's going on
-- function dump(...)
--   print(DataDumper(...), "\n---")
-- end

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

local root = lom.parse(xmlTest)
-- dump(root)

subtest("get all elements", function()
    plan(2)
    local selected = xpath.selectNodes(root, '//element')
    is(#selected, 2);
    is_deeply(selected[1], {
        'text of the first element',
        attr = { "id", "name", id="1", name="element1" },
        tag = "element",
    });
end)

subtest("get the subelement text", function()
    plan(1)
    local text = xpath.selectNodes(root, '/root/element/subelement/text()')
    is_deeply(text, { 'text of the second element' })
end)


subtest("get the first element", function()
    plan(2)
    local nodes = xpath.selectNodes(root, '/root/element[@id="1"]')
    is( #nodes, 1)
    is( nodes[1]['attr']['id'], "1")
end)

done_testing(3)
