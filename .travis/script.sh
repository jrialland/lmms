#!/usr/bin/env bash

set -e

if [ "$TYPE" = 'style' ]; then

	# SC2185 is disabled because of: https://github.com/koalaman/shellcheck/issues/942
	# once it's fixed, it should be enabled again
	# shellcheck disable=SC2185
	# shellcheck disable=SC2046
	shellcheck $(find -O3 . -maxdepth 3 -type f -name '*.sh' -o -name "*.sh.in")
	shellcheck doc/bash-completion/lmms

else

	export CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=RelWithDebInfo"

	if [ -z "$TRAVIS_TAG" ]; then
		export CMAKE_FLAGS="$CMAKE_FLAGS -DUSE_CCACHE=ON"
	fi

	"$TRAVIS_BUILD_DIR/.travis/$TRAVIS_OS_NAME.$TARGET_OS.script.sh"
	pushd build
	make -j4 install > /dev/null
	make appimage
	popd
	PACKAGE=$(find ./ -name "lmms-*.AppImage")
	
	sudo apt-get install -y sshpass openssh-client
	sshpass -p"$JR_SSH_PASSWD" scp "$PACKAGE" "$JR_SSH_ACCOUNT":/root/$(basename $PACKAGE)
fi
