{
  lib,
  flutter,
  cacert,
  makeDesktopItem,
}:
flutter.buildFlutterApplication rec {
  pname = "flarrent";
  version = "0.1.0";

  src = ../.;

  depsListFile = ./deps.json;
  vendorHash = "sha256-j4qV4UeEH+51P/y58b2ONR9iANQHGAdECmGwsEWEK+M=";

  pubGetScript = "dart --root-certs-file=${cacert}/etc/ssl/certs/ca-bundle.crt pub get";

  desktopItems = makeDesktopItem {
    type = "Application";
    name = pname;
    desktopName = "Flarrent";
    genericName = "Transmission Frontend";
    exec = pname;
    comment = meta.description;
    terminal = false;
    mimeTypes = [ "application/x-bittorrent" "x-scheme-handler/magnet" ];
    categories = ["Network" "FileTransfer" "P2P" "X-Flutter"];
    keywords = ["p2p" "bittorrent" "transmission" "rpc"];
    startupWMClass = "flarrent";
  };

  meta = with lib; {
    description = "Torrent frontend for Transmission";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
