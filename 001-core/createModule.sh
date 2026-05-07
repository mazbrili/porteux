#!/bin/bash

MODULENAME=001-core
source "$PWD/../builder-utils/setflags.sh"
SetFlags "$MODULENAME"

# Import utility scripts
source "$BUILDERUTILSPATH/cachefiles.sh"
source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
source "$BUILDERUTILSPATH/slackwarerepository.sh"

if ! isRoot; then
    echo "Please enter admin's password below:"
    su -c "$0 $1"
    exit
fi

echo -e "Building ${MODULENAME} with GoboLinux Hierarchy...\n"

### 1. PERSIAPAN FOLDER
# GOBO_ROOT mengarah ke folder 'packages' yang akan menjadi root module .xzm nantinya
GOBO_ROOT="$MODULEPATH/packages"
mkdir -p $GOBO_ROOT/{Programs,System/Index,System/Settings}

cd $MODULEPATH

### 2. DOWNLOAD SUMBER DAYA
sh $SCRIPTPATH/downloadPackages.sh

### 3. BOOTSTRAP LIBRARIES (Biner)
# Kita tetap butuh ini agar lingkungan build awal memiliki library dasar
for pkg in ncurses zlib xz zstd; do
    installpkg $GOBO_ROOT/${pkg}*.txz > /dev/null 2>&1
done

### 4. CORE COMPILATION & GOBOSPLIT
# Daftar paket yang akan dikompilasi dari source dan diproses oleh gobo_splitter
CORE_PACKAGES=(
    "glibc"
    "zlib-ng"
    "bash"
    "coreutils"
    "sed"
    "grep"
    "tar"
)

for package in "${CORE_PACKAGES[@]}"; do
    echo "--------------------------------------------------------"
    echo "Processing: ${package}"
    echo "--------------------------------------------------------"
    
    # Lokasi instalasi sementara (DESTDIR)
    PKG_TEMP="/tmp/gobo-build-${package}"
    rm -rf "$PKG_TEMP" && mkdir -p "$PKG_TEMP"

    # Jalankan build script (Pastikan skrip ini menerima parameter DESTDIR)
    sh $SCRIPTPATH/deps/${package}.build "$PKG_TEMP" || exit 1
    
    # --- PEMANGGILAN GOBOSPLITTER ---
    # Fungsi: Memindahkan file dari PKG_TEMP ke $GOBO_ROOT/Programs/Package/Version
    # Argumen: SourceDir, PackageName, Version, TargetRoot
    # Kita asumsikan versinya 'current' jika tidak ditentukan di build script
    PACKAGE_VERSION=$(cat "$PKG_TEMP/version" 2>/dev/null || echo "current")
    
    sh "$BUILDERUTILSPATH/gobo_splitter.sh" \
        "$PKG_TEMP" \
        "$package" \
        "$PACKAGE_VERSION" \
        "$GOBO_ROOT"
    
    # Bersihkan temp setelah split
    rm -rf "$PKG_TEMP"
    find $MODULEPATH -mindepth 1 -maxdepth 1 ! \( -name "packages" -o -name "source-slackware" \) -exec rm -rf '{}' \; 2>/dev/null
done

### 5. INTEGRASI BINER (Hybrid)
# Paket biner lainnya tetap diekstrak ke root untuk sementara
# atau Anda bisa menambahkan loop gobo_splitter lagi untuk file .txz
cd $GOBO_ROOT
for txz in *.txz; do
    [ -e "$txz" ] || continue
    installpkg "$txz"
    rm "$txz"
done

### 6. FINALIZE (Stripping & Cache)
# Pindahkan libc agar aman dari stripping agresif
LIBC_PATH=$(find $GOBO_ROOT/Programs/Glibc -name "libc-*" | head -n 1)
if [ ! -z "$LIBC_PATH" ]; then
    mv "$LIBC_PATH" $MODULEPATH/
fi

GenericStrip
AggressiveStrip

# Kembalikan libc ke tempatnya
if [ ! -z "$LIBC_PATH" ]; then
    mv $MODULEPATH/libc-* "$(dirname "$LIBC_PATH")/"
fi

PrepareFilesForCache
Finalize
