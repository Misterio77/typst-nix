# Typst Nix

A dead-simple function to build your typst packages, including those that require [typst packages](https://typst.app/universe).

## Usage

This repo contains a `mkTypstDerivation` function. It's a simple `mkDerivation` wrapper, with a `buildPhase` that calls `typst compile`:

```nix
mkTypstDerivation {
  name = "paper-im-procrastinating-on";
  # Directory containing the typst project
  src = ./.;
  # Main file name
  mainFile = "main.typ";
}
```

Besides the usual `mkDerivation` arguments, it also takes (all of them optional):
- `mainFile`: the main typst file name (relative to `src`). Defaults to `main.typ`.
- `outFormat`: the chosen output format. At the time of writing, typst supports `pdf`, `svg`, and `png`. Default to `pdf`.
- `outputFile`: file name to output. Defaults to `mainFile` with `.typ` replaced by `.${outFormat}` (i.e. `main.pdf`).
- `extraFonts`: extra fonts typst should have access to.
- `extraCompileFlags`: extra arguments to pass to typst compile.
- `typstPackages`: path to a directory containing typst packages.
- `typst`: typst package used to compile, in case you want to use a different one.

The function's available at `default.nix` and also exposed via flake `lib` and `overlays.default` outputs.

### As a flake input

Minimal example:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    typst-nix.url = "github:misterio77/typst-nix";
    typst-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, typst-nix, ... }: {
    packages.x86_64-linux = {
      default = typst-nix.lib.x86_64-linux.mkTypstDerivation {
        name = "ending-world-hunger-with-nix";
        src = ./.;
      };
    });
  };
}
```

Do check [example/flake.nix](example/flake.nix) for a slightly better example.
Also available as a nix flake template:
```bash
nix flake init -t github:misterio77/typst-nix
```

### With a fetcher

``` nix
let
  mkTypstDerivation = import (fetchTarball "https://github.com/misterio77/typst-nix") {};
in
  mkTypstDerivation {
    name = "destroying-capitalism-with-nix";
    src = ./.;
  }
```

## About typst-packages rev

Do note that by, default, you'll use this repo's locked typst-packages version.

If that bothers you (maybe I forgor to update the lock idk), either:

- Use flake inputs follows (see [example/flake.nix](example/flake.nix)); or
- Set `mkTypstDerivation`'s `typstPackages` argument (e.g. to a `fetchTarball` call)
