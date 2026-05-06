#!/bin/bash

# Pastikan variabel ini disesuaikan di environment Anda
GOBO_MODULE_PATH="${GOBO_MODULE_PATH:-/System/Variable/tmp/gobolinux-build}"

CopyToDevel() {
    # Di GoboLinux, file devel ada di /Programs/<Pkg>/<Ver>/include dan /System/Index/include
    mkdir -p "$GOBO_MODULE_PATH"/05-devel/packages > /dev/null 2>&1
    cd "$MODULEPATH"/packages || return

    # Mencari header, static libs, dan metadata kompilasi dalam struktur Gobo
    # Biasanya tersimpan di folder 'include', 'lib/pkgconfig', atau 'Shared/cmake'
    find . -regex '.*\.\(h\|c\|m4\|make\|cmake\|a\|o\|pc\|gir\|deps\|vapi\|in\)$' \
        -exec cp --parents {} "$GOBO_MODULE_PATH"/05-devel/packages \;

    # Penyesuaian Python: Di GoboLinux pathnya adalah Lib/python*/...
    cp -r --parents Lib/python*/site-packages/*-info "$GOBO_MODULE_PATH"/05-devel/packages > /dev/null 2>&1
}

CopyToMultiLanguage() {
    mkdir -p "$GOBO_MODULE_PATH"/08-multilanguage/packages > /dev/null 2>&1
    cd "$MODULEPATH"/packages || return

    # Di GoboLinux, 'share' biasanya di-symlink ke 'Shared'
    # Kita periksa direktori Shared/locale dan Shared/translations
    
    LOCALES=(
        "Shared/locale"
        "Shared/translations"
        "Shared/featherpad/translations"
        "Shared/lxqt/translations"
        "Shared/pavucontrol-qt/translations"
        "Shared/X11/locale"
    )

    for dir in "${LOCALES[@]}"; do
        [ -e "$dir" ] && cp -r --parents "$dir" "$GOBO_MODULE_PATH"/08-multilanguage/packages
    done
}

InstallAdditionalPackages() {
    cd "$MODULEPATH"/packages || return
    # GoboLinux menggunakan 'Compile' atau 'InstallPackage'
    # Jika Anda memiliki file .tar.bz2 (Gobo Package), kita ekstrak manual ke struktur /Programs
    for pkg in "$SCRIPTPATH"/packages/*.tar.bz2; do
        [ -e "$pkg" ] || continue
        # Ekstrak paket ke root sementara
        tar -xjf "$pkg" -C .
    done
    
    # Catatan: Di GoboLive, kita mungkin perlu menjalankan 'SymlinkProgram' 
    # setelah ISO booting untuk mengaitkan folder ke /System/Index
}

MakeModule() {
    # Tetap menggunakan SquashFS dengan kompresi Zstd (standar Porteux/Gobo modern)
    zstdFlags="-comp zstd -b 256K -Xcompression-level 22"
    mksquashfs "${1}" "${2}" $zstdFlags -noappend
}

Finalize() {
    # Versi GoboLinux: Informasi sistem diletakkan di /System/Settings
    mkdir -p "$MODULEPATH"/packages/System/Settings/Porteus
    echo "$MODULENAME.xzm:$(date +%Y%m%d)" > "$MODULEPATH"/packages/System/Settings/Porteus/"$MODULENAME".ver

    # Membuat modul .xzm
    MakeModule "$MODULEPATH"/packages/ "$MODULEPATH"/"$MODULENAME"-Gobo-"$(date +%Y%m%d)".xzm

    # Pembersihan
    rm -fr "$MODULEPATH"/packages/
}

isRoot() {
    # Di GoboLinux, user root tetap memiliki GID 0
    [[ $(id -u) -eq 0 ]]
}
