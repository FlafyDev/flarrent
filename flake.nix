{
  description = "Frontend torrent client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
        ];
      };
    in {
      packages = {
        inherit (pkgs) flarrent;
        default = pkgs.flarrent;
      };

      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [pkg-config flutter327];
      };
    })
    // {
      overlays.default = _final: prev: {
        flarrent = prev.callPackage ./nix/package.nix {};
      };
    };
}
