{
  description = "Test a pinocchio issue on RPi";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.treefmt-nix.flakeModule ];
      systems = import inputs.systems;
      perSystem =
        {
          lib,
          pkgs,
          self',
          ...
        }:
        {
          checks =
            let
              devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
              packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
            in
            lib.filterAttrs (_n: v: v.meta.available && !v.meta.broken) (devShells // packages);
          devShells = {
            default = pkgs.mkShell {
              packages = [ self'.packages.default ];
            };
          };
          packages = {
            default = pkgs.python3.withPackages (_: [ self'.packages.pinocchio ]);
            pinocchio = pkgs.python3Packages.pinocchio;
          };
          treefmt.programs = {
            deadnix.enable = true;
            nixfmt.enable = true;
          };
        };
    };
}
