#!/usr/bin/env lua

require 'Test.More'
local x = require "luaxpath"
local lom = require "lxp.lom"

local xmlTest =
[[
<?xml version="1.0" encoding="ISO-8859-1"?>
<root xmlns:test="https://test.test/">
    <element id="1" name="element1">text of the first element</element>
    <element id="2" name="element2">
      <subelement>text of the second element</subelement>
    </element>
    <test:newElement id="1" name="newElement" test="testing">
      <test>text of the test element</test>
    </test:newElement>
</root>
]]

local root = lom.parse(xmlTest)

subtest("get all elements", function()
    plan(2)
    local selected = x.selectNodes(root, '//element')
    is(#selected, 2);
    is_deeply(selected[1], {
        'text of the first element',
        attr = { "id", "name", id="1", name="element1" },
        tag = "element",
    });
end)

subtest("get the subelement text", function()
    plan(1)
    local text = x.selectNodes(root, '/root/element/subelement/text()')
    is_deeply(text, { 'text of the second element' })
end)

subtest("get the element by attribute id 1", function()
    plan(2)
    local nodes = x.selectNodes(root, '/root/element[@id="1"]')
    is(#nodes, 1);
    is_deeply(nodes[1], {
        'text of the first element',
        attr = { "id", "name", id="1", name="element1" },
        tag = "element",
    });
end)

subtest("get node two by index", function()
    plan(2)
    local nodes = x.selectNodes(root, '/root/element[2]')
    is( #nodes, 1);
    is( nodes[1]['attr']['id'], "2")
end)

subtest("get the first element node, with ignoring the case of element", function()
    plan(2)
    local nodes = x.selectNodes(root, '/root/ELEMENT[1]',true)
    is( #nodes, 1);
    is( nodes[1]['attr']['id'], "1")
end)

subtest("get the newElement node and make use of the namespace in the tag name", function()
    plan(2)
    local nodes = x.selectNodes(root, '/root/test:newElement')
    is( #nodes, 1);
    is( nodes[1]['attr']['name'], "newElement")
end)

subtest("get the node that has a child node that contains a tag name of subelement", function()
    plan(1)
    local nodes = x.selectNodes(root, '//element[subelement="text of the second element"]')
    is( #nodes, 1);
end)

subtest("get any node that has an attribute of test", function()
    plan(1)
    local nodes = x.selectNodes(root, '//*/@test')
    is( #nodes, 1);
end)

subtest("get the node by name", function()
    plan(1)
    local nodes = x.selectNodes(root, '/root/element/node()')
    is( #nodes, 2);
end)

subtest("get all child nodes of root", function()
    plan(1)
    local nodes = x.selectNodes(root, '/root/*')
    is( #nodes, 3);
end)

subtest("get all element nodes that contains an attribute of name which is equal to element", function()
    plan(1)
    local nodes = x.selectNodes(root, '/root/element[contains(@name, "element")]')
    is( #nodes, 2);
end)

subtest("get all element nodes that contains an attribute of name which starts with ele", function()
    plan(1)
    local nodes = x.selectNodes(root, '/root/element[starts-with(@name, "ele")]')
    is( #nodes, 2);
end)

done_testing(12)
