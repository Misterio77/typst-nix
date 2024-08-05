{
  pkgs ? import <nixpkgs> {},
  # Default to flake.lock's rev
  typst-packages ? let
    locked = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.typst-packages.locked;
  in
    fetchTarball {
      url = "https://github.com/${locked.owner}/${locked.repo}/archive/${locked.rev}.tar.gz";
      sha256 = locked.hash;
    },
  ...
}: let
  inherit (pkgs) lib;
  inherit (pkgs.lib) mapAttrsToList escapeShellArgs;
in
  {
    mainFile ? "main.typ",
    outFormat ? "pdf",
    outputFile ? builtins.replaceStrings [".typ"] [".${outFormat}"] mainFile,
    extraFonts ? null,
    extraCompileFlags ? [],
    typstPackages ? {preview = "${typst-packages}/packages/preview";},
    typst ? pkgs.typst,
    ...
  } @ args:
    pkgs.stdenvNoCC.mkDerivation (
      lib.removeAttrs args ["typstPackages"]
      // {
        nativeBuildInputs = (args.nativeBuildInputs or []) ++ [typst];
        XDG_DATA_HOME = pkgs.linkFarm "typst-packages" (mapAttrsToList (name: path: {
            name = "typst/packages/${name}";
            inherit path;
          })
          typstPackages);
        TYPST_FONT_PATHS = extraFonts;
        buildPhase = ''
          runHook preBuild
          mkdir -p $out
          typst compile -f ${outFormat} ${escapeShellArgs extraCompileFlags} "${mainFile}" "$out/${outputFile}"
          runHook postBuild
        '';
      }
    )
