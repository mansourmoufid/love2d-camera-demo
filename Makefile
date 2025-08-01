# NAME must contain only lowercase letters, numbers, or underscores.
NAME:=		love2d_camera_demo

MAKEFILE:=	$(firstword $(MAKEFILE_LIST))
MAKEDIR:=	$(shell cd $(dir $(MAKEFILE)) && pwd)

.PHONY: all
all: $(NAME).love

DEPENDS:= \
	al.lua

LuaJIT:
	git clone https://github.com/LuaJIT/LuaJIT.git
	cd LuaJIT && git checkout v2.1
	cd LuaJIT && git fetch
	cd LuaJIT && git merge

aluminium-library:
	git clone https://github.com/mansourmoufid/aluminium-library.git
	git fetch
	git merge

al.lua: aluminium-library
	cp -f aluminium-library/al.lua al.lua

.PHONY: love
love: $(NAME).love

$(NAME).love: main.lua $(DEPENDS)
	zip $(NAME).zip main.lua $(DEPENDS)
	cp -f $(NAME).zip $(NAME).love

.PHONY: clean-love
clean-love:
	rm -f $(NAME).love

.PHONY: cleanup
cleanup:
	rm -f $(NAME).zip

.PHONY: clean
clean: cleanup clean-love
	dot_clean .
	find . -name .DS_Store | xargs rm -f

.PHONY: check
check: $(DEPENDS)
	luacheck *.lua
