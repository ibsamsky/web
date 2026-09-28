{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.rust-overlay.overlays.default ];
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            just
            openssl
            pnpm
            pkg-config
            (rust-bin.stable.latest.default.override { targets = [ "wasm32-unknown-unknown" ]; })
            worker-build
          ];

          # override any external flags set by .cargo/config.toml, etc. to avoid build errors
          RUSTFLAGS = null;
        };

        treefmt.programs = {
          nixfmt = {
            enable = true;
            strict = true;
          };

          oxfmt.enable = true;
          rustfmt.enable = true;
        };
      };
    };
}
