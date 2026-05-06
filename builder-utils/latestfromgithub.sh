#!/bin/bash

# Fungsi untuk mendapatkan tag versi terbaru
GetLatestVersionTagFromGithub() {
    local repository="$1"
    local project="$2"
    local filterOutVersion="$3"
    local versions
    local versionNormalized

    # Menggunakan API GitHub lebih disarankan di GoboLinux agar lebih reliabel daripada parsing HTML
    versions=$(curl -s "https://api.github.com/repos/${repository}/${project}/tags" | grep -oP '"name": "\K[^"]+')
    
    if [ -z "$versions" ]; then
        # Fallback ke metode scraping jika API limit tercapai
        versions=$(curl -s "https://github.com/${repository}/${project}/tags/" | grep -oP "(?<=/${repository}/${project}/releases/tag/)[^\"]+" | uniq)
    fi

    # Filter alpha, beta, rc, dan filter tambahan
    versions=$(echo "$versions" | grep -vE "alpha|beta|rc[0-9]")
    [ -n "$filterOutVersion" ] && versions=$(echo "$versions" | grep -Ev "$filterOutVersion")

    # Ambil versi terbaru
    version=$(echo "$versions" | sort -V -r | head -n 1)

    echo "${version}"
}

# Fungsi untuk mengunduh source code
DownloadLatestFromGithub() {
    local repository="$1"
    local project="$2"
    local filterOutVersion="$3"
    local version
    local versionClean
    local releaseUrl
    local tagUrl
    local validUrl

    version=$(GetLatestVersionTagFromGithub "${repository}" "${project}" "${filterOutVersion}")
    
    # GoboLinux Convention: Hilangkan awalan 'v' jika ada (misal v1.0 -> 1.0)
    versionClean=$(echo "${version}" | sed 's/^v//')

    # Konstruksi URL untuk rilis biner atau source archive
    releaseUrl="https://github.com/${repository}/${project}/releases/download/${version}/${project}-${versionClean}.tar"
    tagUrl="https://github.com/${repository}/${project}/archive/refs/tags/${version}.tar.gz"

    # Validasi URL (mencari ekstensi yang umum digunakan di Gobo: .tar.gz atau .tar.xz)
    if wget --spider "${releaseUrl}.xz" > /dev/null 2>&1; then
        validUrl="${releaseUrl}.xz"
    elif wget --spider "${releaseUrl}.gz" > /dev/null 2>&1; then
        validUrl="${releaseUrl}.gz"
    else
        validUrl=${tagUrl}
    fi

    # Proses Download
    # Di GoboLinux, kita biasanya mengunduh ke folder kerja saat ini sebelum diproses oleh 'Compile'
    echo "Downloading ${project} version ${versionClean}..." >&2
    
    # Gunakan --content-disposition agar nama file hasil download rapi
    wget --continue --content-disposition "$validUrl"

    # Ambil nama file terakhir yang diunduh
    local filename
    filename=$(basename "$validUrl")
    
    # Jika menggunakan tagUrl, GitHub biasanya menamainya {version}.tar.gz
    # Kita kembalikan informasi yang dibutuhkan untuk skrip build selanjutnya
    echo "$filename $versionClean"
}
