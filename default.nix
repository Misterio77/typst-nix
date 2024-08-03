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
}: {
  mainFile ? "main.typ",
  outFormat ? "pdf",
  outputFile ? builtins.replaceStrings [".typ"] [".${outFormat}"] mainFile,
  extraFonts ? null,
  extraCompileFlags ? [],
  typstPackages ? typst-packages,
  typst ? pkgs.typst,
  ...
} @ args:
pkgs.stdenvNoCC.mkDerivation (args
  // {
    nativeBuildInputs = (args.nativeBuildInputs or []) ++ [typst];
    XDG_CACHE_HOME = pkgs.linkFarm "cache" [
      {
        name = "typst";
        path = typstPackages;
      }
    ];
    TYPST_FONT_PATHS = extraFonts;
    buildPhase = ''
      runHook preBuild
      mkdir -p $out
      typst compile -f ${outFormat} ${pkgs.lib.escapeShellArgs extraCompileFlags} "${mainFile}" "$out/${outputFile}"
      runHook postBuild
    '';
  })
