#!/bin/sh

eval `luarocks path`
export LUA_PATH="./src/?.lua;./src/?/init.lua;$LUA_PATH;"
prove -v t
