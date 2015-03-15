package = "luaxpath"
version = "1.0-1"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "An example for the LuaRocks tutorial.",
   detailed = [[
       This is an example for the LuaRocks tutorial.
       Here we would put a detailed, typically
       paragraph-long description.
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "MIT"
}
dependencies = {
   "lua ~> 5.1",
   "LuaExpat => 1.3",
}
build = {
   type = "builtin",
   modules = {
      ['luaxpath'] = 'src/luaxpath/init.lua',
      ['luaxpath.datadumper'] = 'src/luaxpath/datadumper.lua',
      ['luaxpath.utils'] = 'src/luaxpath/utils.lua',
   },
}
