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
      };
    in {
      packages = rec {
        flarrent = pkgs.callPackage ./nix/package.nix {};
        default = flarrent;
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [flutter];
      };
    })
    // {
      overlays.default = final: prev: {
        flarrent = prev.callPackage ./nix/package.nix {};
      };
      # homeManagerModules.default = import ./nix/hm-module.nix self;
    };
}
