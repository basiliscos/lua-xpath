LUA_DIR= /usr/local/share/lua/5.1

SRC= xpath.lua

install:
	mkdir -p $(LUA_DIR)
	cp $(SRC) $(LUA_DIR)

clean:
	rm -f $(LUA_DIR)/$(SRC)
