#!/bin/sh

eval `luarocks path`
export LUA_PATH="$LUA_PATH;./src/?.lua;./src/?/init.lua;"
export LUA_PATH="$LUA_PATH;./src/?.lua;./src/?/init.lua;"
prove -v t
