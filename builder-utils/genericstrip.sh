#!/bin/bash

# Fungsi bantu untuk membersihkan path di dalam direktori program Gobo
GenericStrip() {
	# GoboLinux menggunakan 'Shared' sebagai ganti 'usr/share'
	rm -f Shared/pixmaps/*.xpm
	
	# Hapus metadata dan log (GoboLinux menyimpan settings di System/Settings)
	rm -rf etc/bash_completion*
	rm -rf etc/logrotate.d

	# Hapus header, dokumentasi, dan info (setara usr/doc, usr/include, dll)
	rm -rf doc
	rm -rf include
	rm -rf info
	rm -rf Shared/doc
	rm -rf Shared/info
	rm -rf Shared/man
	rm -rf Shared/help
	rm -rf Shared/locale
	
	# Hapus file development di dalam library
	# lib di Gobo berada langsung di root program atau di bawah /lib
	rm -rf lib/cmake
	rm -rf lib/pkgconfig
	rm -rf lib/python*/site-packages/*-info
	
	# Hapus file integrasi sistem yang tidak perlu untuk versi lite
	rm -rf Shared/bash-completion
	rm -rf Shared/cmake
	rm -rf Shared/gir-1.0
	rm -rf Shared/vala
	
	# Bersihkan file source dan build artifacts secara rekursif
	find . -name '*.a' -delete
	find . -name '*.c' -delete
	find . -name '*.cpp' -delete
	find . -name '*.h' -delete
	find . -name '*.hpp' -delete
	find . -name '*.la' -delete
	find . -name '*.pc' -delete
	find . -name 'AUTHORS*' -delete
	find . -name 'COPYING*' -delete
	find . -name 'LICENSE*' -delete
	find . -name 'README*' -delete

	# Hapus direktori kosong (khas Gobo: folder Executable, Shared, dll jika kosong)
	find . -type d -empty -delete

	# Stripping ELF (Library dan Executable)
	# Menggunakan standar strip untuk membuang simbol debug dan note
	find . -type f | xargs file | grep ELF | cut -f 1 -d : | xargs strip --strip-debug --strip-unneeded -R .comment* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStrip() {
	# Deteksi fitur strip-section-headers (untuk memperkecil ukuran secara ekstrem)
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	
	# Fokus pada Executable di Gobo (biasanya di folder bin/ atau sbin/)
	find . -type f | xargs file | grep "executable" | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

AggressiveStripAll() {
	[[ $(strip --help | grep "strip-section-headers") ]] && stripSectionHeaders="--strip-section-headers"
	
	# Sikat habis semua ELF (Executable & Shared Object/Library)
	find . -type f | xargs file | grep ELF | cut -f 1 -d : | xargs strip --strip-all ${stripSectionHeaders} -R .comment* -R .eh_frame* -R .note -R .note.ABI-tag -R .note.gnu.build-id -R .note.GNU-stack 2> /dev/null
} > /dev/null 2>&1

if [ "$1" ]; then
	"$1"
fi
