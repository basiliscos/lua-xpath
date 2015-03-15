package = "luaxpath"
version = "1.2-1"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "Simple XPath implementation in the Lua programming language.",
   detailed = [[
       It enables a Lua program to fetch parts of an XML using xpath expressions.
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "LuaExpat >= 1.2.0",
}
build = {
   type = "builtin",
   modules = {
      ['luaxpath'] = 'src/luaxpath/init.lua',
      ['luaxpath.datadumper'] = 'src/luaxpath/datadumper.lua',
      ['luaxpath.utils'] = 'src/luaxpath/utils.lua',
   },
}
