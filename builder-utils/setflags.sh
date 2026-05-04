#!/bin/bash

SetFlags() {
	MODULENAME="$1"
	# GoboLinux menggunakan Nama dan Versi (Contoh: /Programs/PorteuX-Builder/1.0)
	VERSION="1.0" 

	export KERNELVERSION="6.19.5"
	export ARCHITECTURELEVEL="x86-64-v2"
	
	# Flags tetap sama karena ini optimasi compiler (GCC/Clang/Rust)
	export GCCFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -fipa-pta -fno-ident -fmodulo-sched -floop-parallelize-all -fuse-linker-plugin"
	export LDFLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--build-id=none -Wl,-O2 -Wl,--strip-all -Wl,--sort-section=alignment -Wl,-z,pack-relative-relocs"
	export CLANGFLAGS="-O3 -march=$ARCHITECTURELEVEL -mtune=generic -fno-semantic-interposition -fno-trapping-math -ftree-vectorize -fno-unwind-tables -fno-asynchronous-unwind-tables -ffunction-sections -fdata-sections -flto=auto -fno-plt -faddrsig -Wno-unused-command-line-argument"
	export LLDFLAGS="${LDFLAGS} -fuse-ld=lld -Wl,--icf=safe -Wl,--lto-O3 -Wl,--pack-dyn-relocs=relr -Wl,-z,rodynamic"
	export RUSTFLAGS="-Copt-level=3 -Ctarget-cpu=$ARCHITECTURELEVEL -Ztune-cpu=generic -Cstrip=symbols -Clink-arg=-ffunction-sections -Clink-arg=-fdata-sections -Cforce-unwind-tables=no -Clto=fat -Clinker=clang -Clink-arg=-fuse-ld=lld -Clink-arg=-Wl,--gc-sections -Clink-arg=-Wl,-O2 -Clink-arg=-Wl,--strip-all -Clink-arg=-Wl,--icf=safe -Clink-arg=-Wl,--lto-O3 -Cpanic=abort -Cdebuginfo=0 -Cembed-bitcode=yes -Zdylib-lto -Zlocation-detail=none -Ccodegen-units=1"
	export RUSTC_BOOTSTRAP=1 
	
	current_folder=$(dirname "$(realpath "$0")")
	git config --global --add safe.directory "${current_folder}"/.. 2>/dev/null
	export PORTEUXVERSION=$(git -C "${current_folder}"/.. branch --show-current)
	[ ! $PORTEUXVERSION ] && PORTEUXVERSION=$(date -r . +%Y%m%d)

	# Penyesuaian Verifikasi Lingkungan
	# GoboLinux tidak memiliki /etc/slackware-version. Kita cek keberadaan tool 'Compile'.
	if [ -f "/System/Settings/gobo-release" ] || command -v SymlinkProgram > /dev/null; then
		export GOBO_BUILD="current"
		echo "Environment: GoboLinux Detected"
	else
		echo "Fatal error: Script ini sekarang dikonversi untuk lingkungan GoboLinux." && exit 1
	fi

	export SCRIPTPATH="$PWD"
	
	# Lokasi Build disesuaikan dengan standar folder /Files atau /Programs di Gobo
	export PORTEUXBUILDERPATH="/Files/Compile/Intermediate/$MODULENAME"
	export MODULEPATH="/Programs/$MODULENAME/$VERSION"
	export BUILDERUTILSPATH="$SCRIPTPATH/../builder-utils"

	export ARCH=$(uname -m)
	export NUMBERTHREADS=$(nproc --all)
	
	# Gobo tidak menggunakan makepkg Slackware secara default.
	# Jika tetap ingin memaketkan, kita simpan flags-nya.
	export MAKEPKGFLAGS="-l y -c n --compress -0"

	if [ -z ${SYSTEMBITS+x} ] && [ "$(getconf LONG_BIT)" = "64" ]; then
		export SYSTEMBITS="64"
	fi

	# Repositori: Mengarah ke GoboLinux Recipe Store atau Mirror pilihan
	export GOBODOMAIN="https://gobolinux.org"
	export REPOSITORY="$GOBODOMAIN/recipes"
}
