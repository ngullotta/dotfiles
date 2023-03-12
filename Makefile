######################################
#    General installation Makefile   #
######################################
# After working on this for a while, I begin to understand just how easy these
# things can become so dense that they're basically impossible for all but the
# original author (or those _very_ well versed in Makefiles) to understand.
#
# I've done my best to document this file, but some things here stretch my own
# understanding to the point where it's difficult for me to describe them.
######################################

# Ensure a consistent shell
SHELL = /bin/sh

# Set destination to the home dir of the current user
DESTDIR = ${HOME}

# Set srcdir based on our config dir
srcdir = ${abspath .}

# Grab some architecture information for use elsewhere.
# Mostly used when installing stuff from source for some multi-arch support
uname_s = $(shell uname -s | tr '[:upper:]' '[:lower:]')
uname_m = $(shell uname -m)

# Converts the uname versions of these things to their "common" names
COMMON_ARCH.x86_64 = amd64
COMMON_ARCH.aarch64 = arm64

# clear out suffixes; we don't need them anyway
.SUFFIXES:

# Locations of symlinks.  Their source files are below
TARGETS= \
	${DESTDIR}/.gitconfig \
	${DESTDIR}/.config/kitty/kitty.conf \
	${DESTDIR}/.config/mpv \
	${DESTDIR}/.config/nano \
	${DESTDIR}/.config/newsboat \
	${DESTDIR}/.config/polybar \
	${DESTDIR}/.config/sxhkd \
	${DESTDIR}/.local/share/zsh \
	${DESTDIR}/.local/share/scripts \
	${DESTDIR}/.local/bin/newsboat \
	${DESTDIR}/.local/bin/strainer \
	${DESTDIR}/.local/bin/twitch \
	${DESTDIR}/.zshrc

.PHONY: all install uninstall init deinit targets

# Source files for our symlinks
${DESTDIR}/.gitconfig: ${srcdir}/git/.gitconfig
${DESTDIR}/.config/kitty/kitty.conf: ${srcdir}/kitty/kitty.conf
${DESTDIR}/.config/mpv: ${srcdir}/mpv
${DESTDIR}/.config/nano: ${srcdir}/nano
${DESTDIR}/.config/newsboat: ${srcdir}/newsboat
${DESTDIR}/.config/polybar: ${srcdir}/polybar
${DESTDIR}/.config/sxhkd: ${srcdir}/sxhkd
${DESTDIR}/.local/share/zsh: ${srcdir}/.local/share/zsh
${DESTDIR}/.local/share/scripts: ${srcdir}/.local/share/scripts
${DESTDIR}/.local/bin/newsboat: ${srcdir}/.local/bin/newsboat
${DESTDIR}/.local/bin/strainer: ${srcdir}/.local/bin/strainer
${DESTDIR}/.local/bin/twitch: ${srcdir}/.local/bin/twitch
${DESTDIR}/.zshrc: ${srcdir}/zsh/.zshrc


$(TARGETS):
	mkdir -p ${@D}
	ln -sf $< $@

init:
	git submodule update --init --recursive

deinit:
	git submodule deinit --all

targets: $(TARGETS)

install: init targets

uninstall:
	rm $(TARGETS) > /dev/null 2>&1 || true