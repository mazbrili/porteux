#!/bin/bash

SetFlags() {
	MODULENAME="$1"

	systemFullVersion=$(cat /etc/slackware-version)
	systemVersion=${systemFullVersion//* }

	if [[ $systemVersion != *"+" ]]; then
		export SLACKWAREVERSION=$systemVersion
		export PORTEUXBUILD=stable
	else
		export SLACKWAREVERSION=current
		export PORTEUXBUILD=current
	fi

	export SLACKBUILDVERSION=$SLACKWAREVERSION
	export KERNELVERSION="6.13.1"

	export SCRIPTPATH="$PWD"
	export PORTEUXBUILDERPATH="/tmp/porteux-builder-$PORTEUXBUILD"
	export MODULEPATH="$PORTEUXBUILDERPATH/$MODULENAME"
	export BUILDERUTILSPATH="$SCRIPTPATH/../builderutils"

	if [ ! $ARCH ]; then
		export ARCH=$(uname -m)
	fi

	if [ ! $SYSTEMBITS ] && [ `getconf LONG_BIT` == "64" ]; then
		export SYSTEMBITS="64"
 	else
        export SYSTEMBITS=
	fi

	export MAKEPKGFLAGS="-l y -c n --compress -0"
	export ARCHITECTURELEVEL="x86-64-v2"
	export GCCFLAGS="-O3 -march=${ARCHITECTURELEVEL:-x86_64} -mtune=generic -s -fuse-linker-plugin -Wl,--as-needed -Wl,-O1 -ftree-loop-distribute-patterns -fno-semantic-interposition -fno-trapping-math -Wl,-sort-common -fivopts -fmodulo-sched"
	export CLANGFLAGS="-O3 -march=${ARCHITECTURELEVEL:-x86_64} -mtune=generic"
	export NUMBERTHREADS=$(nproc --all)
	export SLACKWAREDOMAIN="http://ftp.slackware.com/pub"
	#export SLACKWAREDOMAIN="http://slackware.uk"
	export REPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/slackware$SYSTEMBITS"
	export PATCHREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS/patches"
	export SOURCEREPOSITORY="$SLACKWAREDOMAIN/slackware/slackware$SYSTEMBITS-$SLACKWAREVERSION/source"
	export SLACKBUILDREPOSITORY="ftp://ftp.slackbuilds.org/pub/slackbuilds/${systemVersion%\+}"
}
