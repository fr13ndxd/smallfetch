{
  description = "Zig project flake";

  inputs = { zig2nix.url = "github:Cloudef/zig2nix"; };

  outputs = { zig2nix, ... }:
    let flake-utils = zig2nix.inputs.flake-utils;
    in (flake-utils.lib.eachDefaultSystem (system:
      let
        env = zig2nix.outputs.zig-env.${system} {
          zig = zig2nix.outputs.packages.${system}.zig.master.bin;
        };
        system-triple = env.lib.zigTripleFromString system;
      in with builtins;
      with env.lib;
      with env.pkgs.lib; rec {
        # nix build .
        packages.default = packages.target.${system-triple}.override {
          # Prefer nix friendly settings.
          zigPreferMusl = false;
          zigDisableWrap = false;
        };

        apps.bundle.target = genAttrs allTargetTriples (target:
          let pkg = packages.target.${target};
          in {
            type = "app";
            program = "${pkg}/bin/master";
          });

        # default bundle
        apps.bundle.default = apps.bundle.target.${system-triple};
        # nix run .
        apps.default = env.app [ ] ''zig build run -- "$@"'';
        # nix run .#build
        apps.build = env.app [ ] ''zig build "$@"'';
        # nix run .#test
        apps.test = env.app [ ] ''zig build test -- "$@"'';

        # nix develop
        devShells.default = env.mkShell { };
      }));
}
