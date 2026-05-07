#!/bin/bash

# Fungsi untuk memisahkan hasil build menjadi modul Core dan Devel
# Penggunaan: GoboSplitter "NamaProgram" "Versi" "FolderDestinasi"
GoboSplitter() {
    local PRGNAM=$1
    local VERSION=$2
    local DEST=$3
    
    local PKG_DIR="/Programs/$PRGNAM/$VERSION"
    local WORK_CORE="$MODULEPATH/work_area/001-core/$PRGNAM"
    local WORK_DEVEL="$MODULEPATH/work_area/05-devel/$PRGNAM"

    echo "[Splitting] Memisahkan $PRGNAM-$VERSION..."

    # Buat folder kerja
    mkdir -p "$WORK_CORE" "$WORK_DEVEL"

    # --- BAGIAN DEVEL (05-devel) ---
    
    # 1. Pindahkan Header
    if [ -d "$DEST$PKG_DIR/include" ]; then
        mkdir -p "$WORK_DEVEL$PKG_DIR"
        mv "$DEST$PKG_DIR/include" "$WORK_DEVEL$PKG_DIR/"
    fi

    # 2. Pindahkan Static Libraries (.a)
    mkdir -p "$WORK_DEVEL$PKG_DIR/Lib"
    find "$DEST$PKG_DIR/Lib" -maxdepth 1 -name "*.a" 2>/dev/null | while read static_lib; do
        mv "$static_lib" "$WORK_DEVEL$PKG_DIR/Lib/"
    done

    # 3. Pindahkan pkgconfig (.pc) - Sangat penting untuk pembangunan selanjutnya
    if [ -d "$DEST$PKG_DIR/Lib/pkgconfig" ]; then
        mkdir -p "$WORK_DEVEL$PKG_DIR/Lib"
        mv "$DEST$PKG_DIR/Lib/pkgconfig" "$WORK_DEVEL$PKG_DIR/Lib/"
    fi

    # 4. Pindahkan CMake config
    if [ -d "$DEST$PKG_DIR/Lib/cmake" ]; then
        mkdir -p "$WORK_DEVEL$PKG_DIR/Lib"
        mv "$DEST$PKG_DIR/Lib/cmake" "$WORK_DEVEL$PKG_DIR/Lib/"
    fi

    # --- BAGIAN RUNTIME (001-core) ---

    # Sisanya adalah runtime (Shared Libs, Bins, Settings)
    cp -a "$DEST"/* "$WORK_CORE/"

    # Hapus folder Lib di devel jika ternyata kosong setelah pemindahan
    [ -d "$WORK_DEVEL$PKG_DIR/Lib" ] && rmdir --ignore-fail-on-non-empty "$WORK_DEVEL$PKG_DIR/Lib"

    echo "[Success] $PRGNAM telah dipisah ke Core dan Devel."
}
