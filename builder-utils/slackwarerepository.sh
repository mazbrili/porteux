#!/bin/bash

GenerateRepositoryUrls() {
	# Folder penyimpanan paket dan source
	local PKG_BASE="$MODULEPATH/packages"
	rm -f $PKG_BASE/FILE_LIST
	rm -f $PKG_BASE/serverPackages.txt
	mkdir -p $PKG_BASE > /dev/null 2>&1
	cd $PKG_BASE
	
	# Ambil daftar file dari repository (Biner)
	wget $REPOSITORY/FILE_LIST -O FILE_LIST -q > /dev/null 2>&1 || \
	wget $REPOSITORY/FILELIST.TXT -O FILE_LIST -q > /dev/null 2>&1 || exit
	
	# Ambil daftar file dari repository Source (Opsional, jika REPOSITORY_SOURCE diset)
	if [ ! -z "$REPOSITORY_SOURCE" ]; then
		wget $REPOSITORY_SOURCE/FILE_LIST -O FILE_LIST_SOURCE -q > /dev/null 2>&1 || true
	fi

	# Bersihkan daftar paket server untuk biner .txz
	rm -f serverPackages.txt
	while IFS= read -r line; do
		if [[ $line == *txz ]]; then
			# Ambil path setelah './'
			echo "${line#*./}" >> serverPackages.txt
		fi
	done < FILE_LIST

	# Sort agar pencarian lebih cepat
	sort -u -o serverPackages.txt serverPackages.txt
}

DownloadPackage() {
	local PRGNAM=$1
	cd $MODULEPATH/packages

	# Jika paket biner sudah ada, jangan download lagi
	if ls ${PRGNAM}-[0-9]*txz >/dev/null 2>&1; then
		return
	fi

	# Cari URL paket biner
	packageUrl=$(grep -E "/${PRGNAM}-[0-9]+" serverPackages.txt | head -n 1)
	if [ ! -z "$packageUrl" ]; then
		echo "Downloading Binary: $packageUrl..."
		wget "$REPOSITORY/$packageUrl" -q || exit
	fi
}

# --- FUNGSI BARU: DownloadSource ---
DownloadSource() {
	local PRGNAM=$1
	local TARGET_DIR="$MODULEPATH/001-core/source-slackware/$PRGNAM"
	
	# Jika folder source sudah ada dan tidak kosong, skip
	if [ -d "$TARGET_DIR" ] && [ "$(ls -A $TARGET_DIR)" ]; then
		return
	fi

	mkdir -p "$TARGET_DIR"

	# Cari folder source di FILE_LIST (mencari direktori yang mengandung nama paket)
	# Slackware source path biasanya: source/[kategori]/[paket]/
	sourcePath=$(grep -E "source/.*/${PRGNAM}/$" $MODULEPATH/packages/FILE_LIST | awk '{print $NF}' | head -n 1)
	
	if [ -z "$sourcePath" ]; then
		# Coba cari tanpa kategori spesifik
		sourcePath=$(grep "/${PRGNAM}/$" $MODULEPATH/packages/FILE_LIST | grep "source/" | awk '{print $NF}' | head -n 1)
	fi

	if [ ! -z "$sourcePath" ]; then
		echo "Fetching Source Folder: $sourcePath"
		# Menggunakan wget rekursif untuk mengambil isi satu folder source
		# -nd (no directories): agar file langsung masuk ke TARGET_DIR tanpa subfolder category
		# -np (no parent): agar tidak naik ke folder di atasnya
		wget -r -np -nd -l 1 -q --show-progress \
			-P "$TARGET_DIR" \
			"$REPOSITORY_SOURCE/${sourcePath#./}"
	else
		echo "Error: Source for $PRGNAM not found in FILE_LIST"
	fi
}
