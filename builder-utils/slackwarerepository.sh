#!/bin/bash

GenerateRepositoryUrls() {
	# GoboLinux biasanya menggunakan direktori /Files/Compile/Recipes untuk daftar resep
	# atau mengambil daftar dari Store.
	rm -f $MODULEPATH/packages/RECIPE_LIST
	rm -f $MODULEPATH/packages/serverPackages.txt
	mkdir -p $MODULEPATH/packages > /dev/null 2>&1
	cd $MODULEPATH/packages
	
	# Mengambil daftar program/resep yang tersedia di repository GoboLinux
	# Gobo menggunakan struktur: Nama/Versi
	wget $REPOSITORY/MANIFEST -O RECIPE_LIST -q > /dev/null 2>&1 || exit

	# Membersihkan dan menyusun daftar paket (mengambil nama folder program)
	# Asumsi format MANIFEST GoboLinux berisi path lengkap ke Recipe
	grep "Recipe" RECIPE_LIST | cut -d' ' -f2 > serverPackages.txt

	# Sort daftar resep agar pencarian lebih cepat
	sort -o serverPackages.txt{,}
}

DownloadPackage() {
	cd $MODULEPATH/packages

	# Di GoboLinux, kita mencari berdasarkan Nama Program (Case Sensitive)
	# Jika folder program sudah ada, lewati
	if [ -d "/Programs/${1}" ]; then
		echo "Program ${1} sudah terpasang di sistem."
		return
	fi

	# Mencari Recipe yang sesuai di serverPackages.txt
	# Gobo menggunakan format Nama/Versi, jadi kita cari yang diawali dengan nama paket
	packagePath=$(grep "^${1}/" serverPackages.txt | head -n 1)
	
	if [ ! -z "$packagePath" ]; then
		echo "Downloading Recipe for: $packagePath..."
		# GoboLinux menggunakan tool 'GetRecipe' atau mengunduh tarball resep
		# Di sini kita simulasikan pengunduhan arsip resep (.tar.bz2)
		wget "$REPOSITORY/$packagePath/Recipe_${1}.tar.bz2" -q > /dev/null 2>&1 || exit
	else
		echo "Package ${1} tidak ditemukan di repository GoboLinux."
	fi
}
