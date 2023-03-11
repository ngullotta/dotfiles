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
	${DESTDIR}/bin/power_menu \
	${DESTDIR}/bin/git-pretty-history \
	${DESTDIR}/.Xdefaults \
	${DESTDIR}/.xprofile \
	${DESTDIR}/.rvmrc \
	${DESTDIR}/.bundle/config \
	${DESTDIR}/.byobu/.tmux.conf \
	${DESTDIR}/.byobu/keybindings.tmux \
	${DESTDIR}/.config/kitty/kitty.conf \
	${DESTDIR}/.config/i3/config \
	${DESTDIR}/.config/i3/lock.sh \
	${DESTDIR}/.config/i3/lock.png \
	${DESTDIR}/.config/polybar/config \
	${DESTDIR}/.config/polybar/start.sh \
	${DESTDIR}/.config/polybar/spotify-status \
	${DESTDIR}/.config/rofi/config \
	${DESTDIR}/.config/rofi/slate.rasi \
	${DESTDIR}/.config/rofi/power_menu.rasi \
	${DESTDIR}/.config/libinput-gestures.conf \
	${DESTDIR}/.config/compton.conf \
	${DESTDIR}/.rvm/hooks/after_cd_nvm

.PHONY: all install init clean targets

# Source files for our symlinks
# ${DESTDIR}/.emacs.d: ${srcdir}/emacs
# ${DESTDIR}/.bash_profile: ${srcdir}/bash.d/profile ${srcdir}/bash.d/bash-git-prompt
# ${DESTDIR}/.gitconfig: ${srcdir}/gitconf/config
# ${DESTDIR}/bin/git-pretty-history: ${srcdir}/gitconf/git-pretty-history
# ${DESTDIR}/bin/power_menu: ${srcdir}/bin/power_menu
# ${DESTDIR}/.Xdefaults: ${srcdir}/x/defaults
# ${DESTDIR}/.xprofile: ${srcdir}/x/profile
# ${DESTDIR}/.rvmrc: ${srcdir}/rvmrc
# ${DESTDIR}/.bundle/config: ${srcdir}/bundler
# ${DESTDIR}/.byobu/.tmux.conf: ${srcdir}/byobu/.tmux.conf
# ${DESTDIR}/.byobu/keybindings.tmux: ${srcdir}/byobu/keybindings.tmux
${DESTDIR}/.config/kitty/kitty.conf: ${srcdir}/kitty/kitty.conf
# ${DESTDIR}/.config/i3/config: ${srcdir}/i3/config
# ${DESTDIR}/.config/i3/lock.sh: ${srcdir}/i3/lock.sh
# ${DESTDIR}/.config/i3/lock.png: ${srcdir}/i3/lock.png
# ${DESTDIR}/.config/polybar/config: ${srcdir}/polybar/config
# ${DESTDIR}/.config/polybar/start.sh: ${srcdir}/polybar/start.sh
# ${DESTDIR}/.config/polybar/spotify-status: ${srcdir}/polybar/spotify-status
# ${DESTDIR}/.config/rofi/config: ${srcdir}/rofi/config
# ${DESTDIR}/.config/rofi/slate.rasi: ${srcdir}/rofi/slate.rasi
# ${DESTDIR}/.config/rofi/power_menu.rasi: ${srcdir}/rofi/power_menu.rasi
# ${DESTDIR}/.config/libinput-gestures.conf: ${srcdir}/libinput-gestures/libinput-gestures.conf
# ${DESTDIR}/.config/compton.conf: ${srcdir}/i3/compton.conf
# ${DESTDIR}/.rvm/hooks/after_cd_nvm: ${srcdir}/rvm_hacks/after_cd_nvm

$(TARGETS):
	mkdir -p ${@D}
	ln -sf $< $@

init:
	git submodule update --init --recursive

targets: $(TARGETS)

install: targets

uninstall: clean
	@rm $(TARGETS) > /dev/null 2>&1 || true

clean: uninstall