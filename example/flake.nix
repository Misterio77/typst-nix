{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    systems.url = "github:nix-systems/default";

    typst-packages.url = "github:typst/packages";
    typst-packages.flake = false;

    # typst-nix.url = "github:misterio77/typst-nix";
    typst-nix.url = "path:../";
    typst-nix.inputs.nixpkgs.follows = "nixpkgs";
    typst-nix.inputs.typst-packages.follows = "typst-packages";
  };

  outputs = {
    nixpkgs,
    typst-nix,
    systems,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    packages = forEachSystem (system: let
      typstNix = typst-nix.lib.${system};
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = typstNix.mkTypstDerivation {
        name = "example";
        src = ./.;
        extraFonts = [pkgs.fira];
        mainFile = "main.typ";
      };
    });
  };
}
