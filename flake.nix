{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSupportedSystem =
        f:
        lib.genAttrs supportedSystems (
          system:
          let
            overlays = [ (import rust-overlay) ];
            pkgs = import nixpkgs {
              inherit system overlays;
            };
          in
          f {
            inherit system pkgs;
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, ... }:
        {
          default =
            with pkgs;
            mkShell {
              packages = [
                cargo-run-bin
                just
                openssl
                pnpm
                pkg-config
                (rust-bin.stable.latest.default.override {
                  targets = [ "wasm32-unknown-unknown" ];
                })
              ];

              shellHook = ''
                # override any external flags set by .cargo/config.toml, etc. to avoid build errors
                export RUSTFLAGS=""
              '';
            };
        }
      );

    };
}
