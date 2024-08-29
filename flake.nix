{
  description = "obs-shaderfilter rewritten in Rust and improved -- with nix!";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rustVersion = pkgs.rust-bin.nightly.latest.default;
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "obs-shaderfilter";
          version = "0.1.0"; # Update this with your actual version
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "fourier-0.1.0" = "sha256-GYoH9iQyJXCxuurhA3dfHgeNY3MiqR6m8dMFnt+orXU=";
              "obs-sys-0.1.2" = "sha256-URgSiGDCrPfd5L2lCPYIol33DsfCOFoJRePgYXDRAG0=";
            };
          };
          buildInputs = with pkgs; [
            llvm.dev
            obs-studio
          ];
          # TODO: should this be in buildInputs?
          nativeBuildInputs = [ rustVersion ];
          inherit LIBCLANG_PATH;
        };

        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              llvm.dev
              obs-studio
            ];
            nativeBuildInputs = [ rustVersion ];
            inherit LIBCLANG_PATH;
          };
      }
    );
}
