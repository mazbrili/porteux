#!/bin/bash

MODULENAME=05-devel

# Memuat utility yang sudah disesuaikan ke versi Gobo pada percakapan sebelumnya
source "$PWD/../builder-utils/setflags.sh"

SetFlags "$MODULENAME"

source "$BUILDERUTILSPATH/genericstrip.sh"
source "$BUILDERUTILSPATH/helper.sh"
# Kita asumsikan skrip ini sudah disesuaikan untuk mengambil paket dari mirror Gobo atau GitHub
# source "$BUILDERUTILSPATH/goborepository.sh" 

if ! isRoot; then
	echo "GoboLinux: Memerlukan hak akses root."
	sudo "$0" "$@"
	exit
fi

echo -e "Building ${MODULENAME} for GoboLinux 17 (${ARCH})...\n"

### 1. Create module folder
mkdir -p "$MODULEPATH/packages" > /dev/null 2>&1
cd "$MODULEPATH"

### 2. Download packages
# Menggunakan skrip downloader yang sudah kita modifikasi sebelumnya untuk mengambil biner Gobo
sh "$SCRIPTPATH/downloadPackages.sh"

# Penanganan Kernel Headers versi GoboLinux
if [ ! -d "$MODULEPATH/packages/Programs/Kernel-Headers" ]; then
	echo "Fetching Kernel Headers for GoboLinux..."
	# Di Gobo, headers biasanya ada di /Programs/Kernel-Headers/Current
	# Kita salin dari sistem host jika tidak ditemukan di folder download
	mkdir -p "$MODULEPATH/packages/Programs/Kernel-Headers"
	cp -a /Programs/Kernel-Headers/Current "$MODULEPATH/packages/Programs/Kernel-Headers/" || exit 1
fi

### 3. Install Packages (Fake Root)
cd "$MODULEPATH/packages"
# Di GoboLinux, kita mengekstrak .tar.bz2 (paket standar Gobo)
for pkg in *.tar.bz2; do
    [ -f "$pkg" ] || continue
    tar -xjf "$pkg" -C .
    rm "$pkg"
done

### 4. Copy language files
# Fungsi ini sudah kita modifikasi untuk mencari di folder 'Shared/locale'
CopyToMultiLanguage

### 5. Module Clean Up (GoboLinux Hierarchy Style)
cd "$MODULEPATH/packages/"

{
# Hapus file yang tidak diperlukan dalam modul devel
find . -name "*.exe" -delete

# Hapus dokumentasi dan file non-essential (Path disesuaikan ke Gobo)
# Di Gobo, 'share' biasanya adalah 'Shared'
rm -fr Shared/doc
rm -fr Shared/info
rm -fr Shared/man
rm -fr Shared/help
rm -fr Shared/icons
rm -fr Shared/locale
rm -fr Shared/applications
rm -fr Shared/bash-completion
rm -fr Shared/cmake-*/Help
rm -fr Shared/devhelp
rm -fr Shared/gnome
rm -fr Shared/doc

# Hapus library yang biasanya sudah ada di modul dasar (Glibc/GCC-Runtime)
# Agar tidak konflik saat deactivasi modul
rm -f Lib/libatomic.so*
rm -f Lib/libgcc_s.so*
rm -f Lib/libgmp.so*
rm -f Lib/libgmpxx.so*
rm -f Lib/libgomp.so*
rm -f Lib/libltdl.so*
rm -f Lib/libstdc++.so*

# Hapus tool yang sudah ada di modul binutils-stripped
rm -f bin/ar
rm -f bin/strip
rm -f Lib/libbfd.so
rm -f Lib/libbfd-*.so
rm -f Lib/libsframe*.so

# Pembersihan folder kosong dan file .la (libtool)
find . -name '*.la' -delete
find . -type d -empty -delete
} >/dev/null 2>&1

# Melakukan stripping biner untuk memperkecil ukuran modul
AggressiveStrip

### 6. Finalize
Finalize
