#!/usr/bin/env nix-shell
#! nix-shell -i make -p gnumake lua luaformatter

NAME = $(shell basename $(shell pwd))
ADDON_FOLDER = ~/LAtlas/eso/ESO/AddOns
LUA_FORMAT = lua-format
XML_FORMAT = tidy -xml -i -q
SRC_DIR = ./src # Directory containing Lua files
LUA_FILES = $(shell find $(SRC_DIR) -name "*.lua")
XML_FILES = $(shell find $(SRC_DIR) -name "*.xml")
ADDON_PATH = $(shell pwd)

all: clean format zip

clean:
	@echo "Removing Build Artifacts"
	-rm $(NAME).zip
	@echo "Done"

# Format all Lua files
format:
	@echo "Formatting Lua files..."
	@for file in $(LUA_FILES); do \
		echo "Formatting $$file"; \
		$(LUA_FORMAT) -i $$file; \
	done
	@echo "Formatting XML files..."
	@for file in $(XML_FILES); do \
		echo "Formatting $$file"; \
		$(XML_FORMAT) -m $$file; \
	done
	@echo "Done."

zip:
	@echo "Exporting Addon"
	git archive HEAD --prefix=$(NAME)/ --format=zip -o $(NAME).zip
	@echo "Done."

link: link-clean link-set

link-clean:
	@echo "Removing $(NAME) from $(ADDON_FOLDER)"
	rm  $(ADDON_FOLDER)/$(NAME)
	@echo "Removed Link"

link-set:
	@echo "Linking $(NAME) into $(ADDON_FOLDER)"
	ln -s $(ADDON_PATH) $(ADDON_FOLDER)/.
	@echo "Done Linking"
