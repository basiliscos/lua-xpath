package = "luaxpath"
version = "1.2-1"
source = {
   url = "git://github.com/basiliscos/lua-xpath"
}
description = {
   summary = "Simple XPath implementation in the Lua programming language.",
   detailed = [[
       It enables a Lua program to fetch parts of an XML using xpath expressions.
   ]],
   homepage = "https://github.com/basiliscos/lua-xpath",
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "luaexpat >= 1.2",
}
build = {
   type = "builtin",
   modules = {
      ['luaxpath'] = 'src/luaxpath/init.lua',
      ['luaxpath.datadumper'] = 'src/luaxpath/datadumper.lua',
      ['luaxpath.utils'] = 'src/luaxpath/utils.lua',
   },
   copy_directories = { "doc", "t" }
}
