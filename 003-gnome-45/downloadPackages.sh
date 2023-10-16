#!/bin/sh
source "$PWD/../builder-utils/slackwarerepository.sh"

REPOSITORY="$1"

GenerateRepositoryUrls "$REPOSITORY"

DownloadPackage "accountsservice" &
DownloadPackage "aspell" &
DownloadPackage "dconf" &
DownloadPackage "editorconfig-core-c" &
DownloadPackage "enchant" &
DownloadPackage "ffmpegthumbnailer" &
DownloadPackage "gexiv2" &
DownloadPackage "glade" &
DownloadPackage "gjs" &
DownloadPackage "glib-networking" &
wait
DownloadPackage "gperf" &
DownloadPackage "graphene" &
DownloadPackage "gsettings-desktop-schemas" &
DownloadPackage "gst-plugins-bad-free" &
DownloadPackage "gst-plugins-base" &
DownloadPackage "gst-plugins-good" &
DownloadPackage "gst-plugins-libav" &
DownloadPackage "gstreamer" &
DownloadPackage "gtk4" &
wait
DownloadPackage "hyphen" &
DownloadPackage "ibus" &
DownloadPackage "libcanberra" &
DownloadPackage "libgtop" &
DownloadPackage "libhandy" &
DownloadPackage "libnma" &
DownloadPackage "libsoup3" &
DownloadPackage "libxklavier" &
wait
DownloadPackage "libyaml" &
DownloadPackage "openssl" &
DownloadPackage "pipewire" &
DownloadPackage "vte" &
DownloadPackage "woff2" &
DownloadPackage "xorg-server-xwayland" &
wait

### packages that require specific striping

DownloadPackage "gtk+3" &
wait

### temporary packages for further building

DownloadPackage "boost" &
DownloadPackage "cups" &
DownloadPackage "dbus-python" &
DownloadPackage "egl-wayland" &
DownloadPackage "iso-codes" &
DownloadPackage "krb5" &
DownloadPackage "libglvnd" &
wait
DownloadPackage "libsass" & # required by gnome-console
DownloadPackage "libwnck3" &
DownloadPackage "python-pip" &
DownloadPackage "sassc" & # required by gnome-console
DownloadPackage "xtrans" &
wait

### script clean up

rm FILE_LIST
rm serverPackages.txt