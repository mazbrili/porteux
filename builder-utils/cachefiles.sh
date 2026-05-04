#!/bin/bash

PrepareFilesForCacheDE() {
	mkdir -p "$PORTEUXBUILDERPATH/caches" > /dev/null 2>&1
	cp -r "$PORTEUXBUILDERPATH/caches/" "$PORTEUXBUILDERPATH/caches-bkp"
	PrepareFilesForCache
}

PrepareFilesForCache() {
	# ldconfig tetap digunakan tetapi diarahkan ke struktur folder Gobo
	ldconfig -r "$MODULEPATH/"

	# Copy mime packages (Gobo: Shared/mime)
	mkdir -p "$PORTEUXBUILDERPATH/caches/mime/packages" > /dev/null 2>&1
	cp "$MODULEPATH/Shared/mime/packages"/* "$PORTEUXBUILDERPATH/caches/mime/packages" > /dev/null 2>&1

	# Copy desktop files (Gobo: Shared/applications)
	mkdir -p "$PORTEUXBUILDERPATH/caches/applications" > /dev/null 2>&1
	cp "$MODULEPATH/Shared/applications"/*.desktop "$PORTEUXBUILDERPATH/caches/applications/" > /dev/null 2>&1

	# Copy glib schemas (Gobo: Shared/glib-2.0/schemas)
	mkdir -p "$PORTEUXBUILDERPATH/caches/schemas" > /dev/null 2>&1
	cp "$MODULEPATH/Shared/glib-2.0/schemas"/*.xml "$PORTEUXBUILDERPATH/caches/schemas/" > /dev/null 2>&1

	# Copy gdk-pixbuf loaders (Gobo: lib/gdk-pixbuf-2.0/...)
	mkdir -p "$PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/loaders" > /dev/null 2>&1
	cp "$MODULEPATH/lib/gdk-pixbuf-2.0"/2.10.0/loaders/*.so "$PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/loaders" > /dev/null 2>&1
}

GenerateCaches() {
	# Mime Cache
	if [ "$(ls -A $PORTEUXBUILDERPATH/caches/mime/packages 2>/dev/null)" ]; then
		mkdir -p "$MODULEPATH/Shared/mime" > /dev/null 2>&1
		update-mime-database "$PORTEUXBUILDERPATH/caches/mime"
		cp "$PORTEUXBUILDERPATH/caches/mime/mime.cache" "$MODULEPATH/Shared/mime/"
	fi

	# Desktop Database
	if [ "$(ls -A $PORTEUXBUILDERPATH/caches/applications 2>/dev/null)" ]; then
		mkdir -p "$MODULEPATH/Shared/applications" > /dev/null 2>&1
		update-desktop-database "$PORTEUXBUILDERPATH/caches/applications"
		cp "$PORTEUXBUILDERPATH/caches/applications/mimeinfo.cache" "$MODULEPATH/Shared/applications/"
	fi

	# Glib Schemas
	if [ "$(ls -A $PORTEUXBUILDERPATH/caches/schemas 2>/dev/null)" ]; then
		mkdir -p "$MODULEPATH/Shared/glib-2.0/schemas" > /dev/null 2>&1
		glib-compile-schemas "$PORTEUXBUILDERPATH/caches/schemas"
		cp "$PORTEUXBUILDERPATH/caches/schemas/gschemas.compiled" "$MODULEPATH/Shared/glib-2.0/schemas/"
	fi

	# GDK Pixbuf Loaders
	# Di GoboLinux, path di dalam loaders.cache harus menunjuk ke direktori /Programs/Nama/Version/lib
	if [ "$(ls -A $PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/loaders 2>/dev/null)" ]; then
		mkdir -p "$MODULEPATH/lib/gdk-pixbuf-2.0/2.10.0" > /dev/null 2>&1
		gdk-pixbuf-query-loaders "$PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/loaders"/*.so > "$MODULEPATH/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
		# Penyesuaian path agar runtime Gobo benar
		sed -i "s|$PORTEUXBUILDERPATH/caches/gdk-pixbuf-2.0/loaders|/System/Index/lib/gdk-pixbuf-2.0/2.10.0/loaders|g" "$MODULEPATH/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
	fi
}
