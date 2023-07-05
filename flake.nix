{
  description = "Frontend torrent client";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, dart-flutter }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlays.default
              dart-flutter.overlays.default
            ];
          };
        in
        {
          packages = {
            inherit (pkgs) torrent-frontend;
            default = pkgs.torrent-frontend;
          };
          devShell = pkgs.mkFlutterShell {
            linux = {
              enable = true;
            };
          };
        }) // {
      overlays.default = final: prev:
        let
          pkgs = import nixpkgs {
            inherit (prev) system;
            overlays = [ dart-flutter.overlays.default ];
          };
        in
        {
          torrent-frontend = pkgs.callPackage ./nix/package.nix { };
        };
    };
}
