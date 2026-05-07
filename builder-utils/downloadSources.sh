#!/bin/bash
source "$BUILDERUTILSPATH/slackwarerepository.sh"

# Fungsi untuk mengunduh SOURCE, bukan BINARI
DownloadSlackSource() {
    local pkg=$1
    echo "[Source] Mengunduh source untuk: $pkg..."
    
    # Mirror Slackware Source (sesuaikan dengan versi yang Anda gunakan, misal 15.0 atau current)
    local SOURCE_URL="https://mirrors.slackware.com/slackware/slackware64-current/source"
    
    # Cari lokasi paket di kategori mana (base, network, dsb)
    # Ini memerlukan pencarian di FILE_LIST slackware
    local PKG_PATH=$(grep "/$pkg/" FILE_LIST | grep "source/" | head -n 1 | awk '{print $NF}')
    
    if [ ! -z "$PKG_PATH" ]; then
        mkdir -p "$MODULEPATH/001-core/source-slackware/$pkg"
        wget -r -np -nd -l 1 -A "*" "$SOURCE_URL/${PKG_PATH%/*}/" -P "$MODULEPATH/001-core/source-slackware/$pkg"
    else
        echo "[Error] Source $pkg tidak ditemukan di mirror."
    fi
}
