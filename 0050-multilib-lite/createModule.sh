#!/bin/bash

# Nama program/modul di GoboLinux
MODULENAME="MultilibLite"
VERSION="1.0"
TARGET_DIR="/Programs/$MODULENAME/$VERSION"

export SYSTEMBITS=

# Asumsi builder-utils sudah disesuaikan dengan Gobo
source "$PWD/../builder-utils/setflags.sh"
SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"

if ! isRoot; then
    echo "Harap jalankan sebagai superuser (root):"
    sudo "$0" "$1"
    exit
fi

echo -e "Membangun ${MODULENAME} untuk GoboLinux Layout...\n"

# 1. Gunakan Compile atau CreateRoot agar sesuai dengan gaya Gobo
mkdir -p "$TARGET_DIR"/{lib,Shared,System/Settings} 2>/dev/null
cd "$TARGET_DIR"

# 2. Proses Download (Tetap menggunakan skrip internal Anda)
sh $SCRIPTPATH/downloadPackages.sh

### 3. Pemrosesan Library dengan Layout Gobo
# Di GoboLinux, library diletakkan di bawah folder 'lib' di dalam direktori Program terkait.

currentPackage="LibC"
echo "Processing $currentPackage..."
# (Logika ekstraksi tetap, namun output diarahkan ke $TARGET_DIR/lib)
# Contoh pemindahan spesifik:
# cp -P lib/libgssapi_krb5.* "$TARGET_DIR/lib/"

### 4. Pembersihan (GoboLinux Clean-up)
# GoboLinux sangat bersih; kita tidak butuh /usr atau /var di dalam folder program.
{
    # Hapus file yang tidak perlu
    rm -rf "$TARGET_DIR/System/Settings" # Jika tidak ada konfigurasi khusus
    rm -rf "$TARGET_DIR/Shared/man"      # Hapus manual page untuk versi lite
    rm -rf "$TARGET_DIR/Shared/doc"
    
    # Filter binari: Gobo menggunakan folder 'Executable'
    # Jika tidak butuh executable, folder ini bisa dikosongkan
    find "$TARGET_DIR/bin" -type f ! -name "ldconfig" -delete 2>/dev/null
} >/dev/null 2>&1

### 5. Stripping (Sesuai dengan toolchain GoboLinux)
# Kita pindahkan lib yang sensitif sebelum stripping massal
mkdir -p /tmp/gobo_backup
mv "$TARGET_DIR/lib/libc.so"* /tmp/gobo_backup/

GenericStrip "$TARGET_DIR"
AggressiveStrip "$TARGET_DIR"

mv /tmp/gobo_backup/* "$TARGET_DIR/lib/"
rmdir /tmp/gobo_backup

### 6. Finalisasi GoboLinux (Symlink)
# Langkah terpenting di Gobo: Membuat symlink agar system mengenali library ini
# Biasanya menggunakan tool 'SymlinkProgram'
if command -v SymlinkProgram > /dev/null; then
    SymlinkProgram "$MODULENAME" "$VERSION"
fi

echo "Pembangunan $MODULENAME selesai di $TARGET_DIR"
