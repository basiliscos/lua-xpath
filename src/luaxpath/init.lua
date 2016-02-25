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

-----------------------------------------------------------------------------
-- Declare module and import dependencies
-----------------------------------------------------------------------------

local XPath = {}
XPath.__index = XPath

function XPath._new(option)
	local o = { _result_table = {}, _option = option }
	setmetatable(o, XPath)
	return o
end

local function _split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end


-- local resultTable,option = {},nil

-----------------------------------------------------------------------------
-- Supported functions
-----------------------------------------------------------------------------

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


local function match(tag,tagAttr,tagExpr,nextTag)
	local expression,evalTag

	-- check if its a wild card
	if tagExpr == "*" then
		return true
	end

	-- check if its empty
	if tagExpr == "" then
		if tag == nextTag then
			return false,1
		else
			return false,0
		end
	end

	-- check if there is an expression to evaluate
	if tagExpr:find("[[]") ~= nil and tagExpr:find("[]]") ~= nil then
		evalTag = tagExpr:sub(1,tagExpr:find("[[]")-1)
		expression = tagExpr:sub(tagExpr:find("[[]")+1,tagExpr:find("[]]")-1)
		if evalTag ~= tag then
			return false
		end
	else
		return (tag == tagExpr)
	end

	-- check if the expression is an attribute
	if expression:find("@") ~= nil then
		local evalAttr,evalValue
		evalAttr = expression:sub(expression:find("[@]")+1,expression:find("[=]")-1)
		evalValue = string.gsub(expression:sub(expression:find("[=]")+1),"'","")
		evalValue = evalValue:gsub("\"","")
		if tagAttr[evalAttr] ~= evalValue then
			return false
		else
			return true
		end
	end
end

function XPath:parseNodes(tags, xmlTable, counter)
	if counter > #tags then
		return nil
	end
	local currentTag = tags[counter]
	local nextTag
	if #tags > counter then
		nextTag = tags[counter+1]
	end
	for _,value in ipairs(xmlTable) do
		if type(value) == "table" then
			if value.tag ~= nil and value.attr ~= nil then
				local x,y = match(value.tag,value.attr,currentTag,nextTag)
				if x then
					if #tags == counter then
						self:_insert_leaf(value)
					else
						self:parseNodes(tags,value,counter+1)
					end
				else
					if y ~= nil then
						if y == 1 then
							if counter+1 == #tags then
								self:_insert_leaf(value)
							else
								self:parseNodes(tags,value,counter+2)
							end
						else
							self:parseNodes(tags,value,counter)
						end
					end
				end
			end
		end
	end
end

local function selectNodes(xml,xpath)
	assert(type(xml) == "table")
	assert(type(xpath) == "string")

	local xmlTree = { xml }
  local option
	local tags = _split(xpath,'[\\/]+')

	local lastTag = tags[#tags]
	if lastTag == "text()" or lastTag == "node()" or lastTag:find("@") == 1 then
		option = tags[#tags]
		table.remove(tags,#tags)
	end

	if xpath:find("//") == 1 then
		table.insert(tags,1,"")
	end

	local ctx = XPath._new(option)
	ctx:parseNodes(tags, xmlTree, 1)
	return ctx._result_table
end

return {
	selectNodes = selectNodes,
}

