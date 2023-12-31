{
  lib,
  flutter,
  cacert,
  makeDesktopItem,
  copyDesktopItems,
}:
flutter.buildFlutterApplication rec {
  pname = "flarrent";
  version = "0.1.0";

  src = ../.;

  nativeBuildInputs = [copyDesktopItems];

  depsListFile = ./deps.json;
  vendorHash = "sha256-Fyg3AKWbq8Q8sbrKCQ9ptFBlYxa9AMeJY/r1W/21uyY=";

  pubGetScript = "dart --root-certs-file=${cacert}/etc/ssl/certs/ca-bundle.crt pub get";

  desktopItems = makeDesktopItem {
    name = pname;
    comment = meta.description;
    exec = "${pname} --torrent %U";
    terminal = false;
    type = "Application";
    mimeTypes = ["application/x-bittorrent" "x-scheme-handler/magnet"];
    categories = ["Network" "FileTransfer" "P2P" "X-Flutter"];
    keywords = ["p2p" "bittorrent" "transmission" "rpc"];
    startupWMClass = "flarrent";
    desktopName = "Flarrent";
    genericName = "Transmission Frontend";
  };

  meta = with lib; {
    description = "Torrent frontend for Transmission";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
