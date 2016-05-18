#!/bin/bash
set -ev
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
	DIR="$(pwd)"
	cd ..
	export SWIFT_VERSION=swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a
	wget https://swift.org/builds/development/ubuntu1404/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu14.04.tar.gz
	tar xzf $SWIFT_VERSION-ubuntu14.04.tar.gz
	export PATH="${PWD}/${SWIFT_VERSION}-ubuntu14.04/usr/bin:${PATH}"
	cd "$DIR"
else
	export SWIFT_VERSION=swift-DEVELOPMENT-SNAPSHOT-2016-05-03-a
	curl -O https://swift.org/builds/development/xcode/${SWIFT_VERSION}/${SWIFT_VERSION}-osx.pkg
	sudo installer -pkg ${SWIFT_VERSION}-osx.pkg -target /
	export TOOLCHAINS=swift
fi
