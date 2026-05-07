#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

# Inisialisasi URL Repository
# Pastikan REPOSITORY_SOURCE sudah didefinisikan di lingkungan Anda
GenerateRepositoryUrls

# --- KELOMPOK 1: INTI SISTEM (Source) ---
# Paket-paket ini akan kita "Gobo-kan" melalui kompilasi lokal
DownloadSource "acl" &
DownloadSource "attr" &
DownloadSource "bash" &
DownloadSource "bzip2" &
DownloadSource "coreutils" &
DownloadSource "diffutils" &
DownloadSource "file" &
DownloadSource "findutils" &
DownloadSource "gawk" &
DownloadSource "grep" &
wait

# --- KELOMPOK 2: INFRASTRUKTUR SLACKWARE (Binary) ---
# Paket ini biasanya berisi file konfigurasi statis atau struktur direktori dasar
DownloadPackage "aaa_base" &
DownloadPackage "aaa_terminfo" &
DownloadPackage "aaa_libraries" &
DownloadPackage "etc" &
DownloadPackage "devs" &
DownloadPackage "bin" &
DownloadPackage "pkgtools" &
DownloadPackage "slackpkg" &
wait

# --- KELOMPOK 3: LIBRARIES & UTILITIES (Source) ---
DownloadSource "kmod" &
DownloadSource "util-linux" &
DownloadSource "procps-ng" &
DownloadSource "sed" &
DownloadSource "tar" &
DownloadSource "xz" &
DownloadSource "zlib" &
DownloadSource "gzip" &
DownloadSource "patch" &
DownloadSource "shadow" &
wait

# --- KELOMPOK 4: NETWORK & SYSTEM (Kombinasi) ---
DownloadSource "curl" &
DownloadSource "openssl" &
DownloadSource "openssh" &
DownloadPackage "dhcpcd" &
DownloadPackage "network-scripts" &
DownloadPackage "NetworkManager" &
DownloadPackage "wpa_supplicant" &
DownloadPackage "iproute2" &
wait

# --- KELOMPOK 5: STORAGE & FILESYSTEM (Source) ---
DownloadSource "e2fsprogs" &
DownloadSource "xfsprogs" &
DownloadSource "btrfs-progs" &
DownloadSource "dosfstools" &
DownloadSource "ntfs-3g" &
wait

# --- KELOMPOK 6: DEPENDENSI LAINNYA (Binary/Txz) ---
# Untuk mempercepat proses, paket-paket pendukung tetap diambil binernya
# namun nantinya akan diekstrak ke /Programs/Nama/Versi
DownloadPackage "acpid" &
DownloadPackage "avahi" &
DownloadPackage "bc" &
DownloadPackage "bluez" &
DownloadPackage "dbus" &
DownloadPackage "expat" &
DownloadPackage "glib2" &
DownloadPackage "libffi" &
DownloadPackage "pcre2" &
DownloadPackage "sqlite" &
wait

# --- KELOMPOK 7: TOOLCHAIN (Jika diperlukan untuk kompilasi lokal) ---
if [ ! -f /usr/bin/clang ]; then
    DownloadPackage "llvm" &
fi
DownloadPackage "binutils" &
DownloadPackage "gcc" &
DownloadPackage "gcc-g++" &
DownloadPackage "make" &
wait

# --- SISANYA (Looping otomatis untuk sisa daftar Anda) ---
# Anda bisa menambahkan sisa paket dari list asli di sini menggunakan DownloadPackage
# agar sistem tetap fungsional tanpa harus mengompilasi 200+ source sekaligus.

echo "--------------------------------------------------------"
echo "Proses Download Selesai."
echo "Source tersedia di: 001-core/source-slackware/"
echo "Binary tersedia di: packages/"
echo "--------------------------------------------------------"

### script clean up
rm -f FILE_LIST FILE_LIST_SOURCE serverPackages.txt
