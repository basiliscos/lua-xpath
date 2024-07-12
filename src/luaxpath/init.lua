-----------------------------------------------------------------------------
-- XPath module based on LuaExpat
-- Description: Module that provides xpath capabilities to xmls.
-- Author: Gal Dubitski
-- Version: 0.1
-- Date: 2008-01-15
-----------------------------------------------------------------------------
-- Version: 1.2
-- Author: Ivan Baidakou (basiliscos)
-- Date: 2015-03-14
-----------------------------------------------------------------------------
-- Version: 1.2.3
-- Author: blumf
-- Date: 2015-02-20
-----------------------------------------------------------------------------
-- Version: 1.3.0
-- Author: Rohan de Jongh (roebou / thepeanutgalleryandco) + ChatGPT (4.0)
-- Date: 2024-07-12
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------

local XPath = {}
XPath.__index = XPath

--- Creates a new XPath object.
-- @param option The option for selecting nodes (e.g., text(), node()).
-- @param ignoreCase Boolean to ignore case in tag matching.
-- @return A new XPath object.
function XPath._new(option, ignoreCase)
    local o = { _result_table = {}, _option = option, _ignoreCase = ignoreCase }
    setmetatable(o, XPath)
    return o
end

--- Splits a string by a given pattern.
-- @param str The string to split.
-- @param pat The pattern to split by.
-- @return A table containing the split parts.
local function _split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t, cap)
        end
        last_end = e + 1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

-----------------------------------------------------------------------------
-- Supported functions
-----------------------------------------------------------------------------

--- Evaluates a predicate against a value.
-- @param value The value to evaluate.
-- @param predicate The predicate to evaluate.
-- @param ignoreCase Boolean to ignore case in tag matching.
-- @return The result of the predicate evaluation.
local function eval_predicate(value, predicate, ignoreCase)
    -- Check if the predicate is a numeric index
    if predicate:match("^%d+$") then
        return tonumber(predicate)
    end

    -- Check for attribute equality, e.g., @attr='value'
    local attr, val = predicate:match("@([%w:]+)=['\"]([^'\"]+)['\"]")
    if attr and val then
        local v = value.attr and value.attr[attr]
        if ignoreCase then
            return v and v:lower() == val:lower()
        else
            return v == val
        end
    end

    -- Check for element equality, e.g., element='value'
    local element
    element, val = predicate:match("([%w:]+)=['\"]([^'\"]+)['\"]")
    if element and val then
        for _, subValue in ipairs(value) do
            if type(subValue) == "table" and subValue.tag == element then
                local v = subValue[1]
                if ignoreCase then
                    return v and v:lower() == val:lower()
                else
                    return v == val
                end
            end
        end
    end

    -- Check for functions like contains() and starts-with()
    local func, param, pattern = predicate:match("([%w-]+)%((@[%w:]+),%s*['\"]([^'\"]+)['\"]%)")
    if func == "contains" then
        local attr2 = param:match("@([%w:]+)")
        if attr2 then
            local v = value.attr and value.attr[attr2]
            if ignoreCase then
                return v and v:lower():find(pattern:lower()) ~= nil
            else
                return v and v:find(pattern) ~= nil
            end
        end
    elseif func == "starts-with" then
        local attr3 = param:match("@([%w:]+)")
        if attr3 then
            local v = value.attr and value.attr[attr3]
            if ignoreCase then
                return v and v:lower():sub(1, #pattern) == pattern:lower()
            else
                return v and v:sub(1, #pattern) == pattern
            end
        end
    end

    return false
end

--- Matches a tag against an expression.
-- @param tag The tag to match.
-- @param tagExpr The expression to match against.
-- @param value The value to match.
-- @param ignoreCase Boolean to ignore case in tag matching.
-- @return True if the tag matches the expression, otherwise false.
local function match(tag, tagExpr, value, ignoreCase)
    local expression, evalTag

    -- Match any tag
    if tagExpr == "*" then
        return true
    end

    -- Match root tag
    if tagExpr == "" then
        return true
    end

    -- Match by numeric index, e.g., tag[1]
    local numericIndex = tonumber(tagExpr:match("%[(%d+)%]"))
    if numericIndex then
        return true, numericIndex
    end

    -- Match predicates, e.g., tag[@attr='value']
    if tagExpr:find("%[") ~= nil and tagExpr:find("%]") ~= nil then
        evalTag = tagExpr:sub(1, tagExpr:find("%[") - 1)
        expression = tagExpr:sub(tagExpr:find("%[") + 1, tagExpr:find("%]") - 1)
        if ignoreCase then
            if evalTag:lower() ~= tag:lower() then
                return false
            end
        else
            if evalTag ~= tag then
                return false
            end
        end

        -- Evaluate numeric predicates directly
        if tonumber(expression) then
            return tonumber(expression)
        end

        return eval_predicate(value, expression, ignoreCase)
    else
        -- Match by tag name
        if ignoreCase then
            return (tag:lower() == tagExpr:lower())
        else
            return (tag == tagExpr)
        end
    end
end

--- Inserts a leaf node into the result table.
-- @param self The XPath object.
-- @param leaf The leaf node to insert.
function XPath:_insert_leaf(leaf)
    local option = self._option
    if type(leaf) == "table" then
        local value
        if option == nil then
            value = leaf
        elseif option == "text()" then
            value = leaf[1]
        elseif option == "node()" then
            value = leaf.tag
        elseif option:find("@") == 1 then
            value = leaf.attr[option:sub(2)]
        end
        table.insert(self._result_table, value)
    end
end

--- Parses XML nodes recursively according to the provided tags.
-- @param self The XPath object.
-- @param tags The tags to match.
-- @param xmlTable The XML table to parse.
-- @param counter The current tag index.
-- @param recursive Whether to parse recursively.
function XPath:parseNodes(tags, xmlTable, counter, recursive)
    if counter > #tags then
        return nil
    end
    local currentTag = tags[counter]

    local tagMatchCount = 0
    for idx, value in ipairs(xmlTable) do
        if type(value) == "table" then
            if value.tag ~= nil and value.attr ~= nil then
                local x, y = match(value.tag, currentTag, value, self._ignoreCase)
                if type(x) == "number" then
                    if x == idx then
                        self:parseNodes(tags, { value }, counter + 1)
                    end
                elseif x then
                    tagMatchCount = tagMatchCount + 1
                    if y then
                        if tagMatchCount == y then
                            if #tags == counter then
                                self:_insert_leaf(value)
                            else
                                self:parseNodes(tags, value, counter + 1)
                            end
                        end
                    else
                        if #tags == counter then
                            self:_insert_leaf(value)
                        else
                            self:parseNodes(tags, value, counter + 1)
                        end
                    end
                end
                -- Recursively parse children if starting with "//"
                if recursive and counter == 1 then
                    self:parseNodes(tags, value, counter, true)
                end
            end
        end
    end
end

--- Selects nodes from the XML document based on the given XPath expression.
-- @param xml The XML table to search.
-- @param xpath The XPath expression.
-- @param ignoreCase Boolean to ignore case in tag matching.
-- @return A table containing the matched nodes.
local function selectNodes(xml, xpath, ignoreCase)
    assert(type(xml) == "table")
    assert(type(xpath) == "string")

    local xmlTree = { xml }
    local option
    local tags = _split(xpath, '[\\/]+')

    local lastTag = tags[#tags]
    if lastTag == "text()" or lastTag == "node()" or lastTag:find("@") == 1 then
        option = tags[#tags]
        table.remove(tags, #tags)
    end

    local recursive = false
    if xpath:find("//") == 1 then
        table.insert(tags, 1, "")
        recursive = true
    end

    local ctx = XPath._new(option, ignoreCase)
    ctx:parseNodes(tags, xmlTree, 1, recursive)
    return ctx._result_table
end

return {
    selectNodes = selectNodes,
}
