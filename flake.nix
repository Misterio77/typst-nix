{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";

    # You're  advised to use inputs.typst-packages.follows to replace this one.
    # As I might not keep it up to date.
    typst-packages.url = "github:typst/packages";
    typst-packages.flake = false;
  };

  outputs = { nixpkgs, systems, typst-packages, ... }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in rec {
    overlays.default = (pkgs: _: {
      mkTypstDerivation = import ./. { inherit typst-packages pkgs; };
    });

    lib = forEachSystem (system: {
      inherit (overlays.default nixpkgs.legacyPackages.${system} null) mkTypstDerivation;
    });

    templates.default.path = ./example;
  };
}
