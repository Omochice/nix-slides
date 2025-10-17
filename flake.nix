{
  description = "My touying slides";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      nur-packages,
      typst-packages,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nur-packages.overlays.default ];
        };
        typstPackage = pkgs.stdenvNoCC.mkDerivation {
          name = "typst-package-cache";
          src = pkgs.symlinkJoin {
            name = "typst-package-src";
            paths = [ "${typst-packages}/packages" ];
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p "$out"
            cp -LR --reflink=auto --no-preserve=mode -t "$out" "$src"/*
          '';
        };
        fonts = with pkgs; [
          ibm-plex-sans-jp
          noto-fonts-color-emoji
        ];
        font-path = builtins.concatStringsSep ":" fonts;
        typst-compile =
          inputfile: outputfile:
          pkgs.stdenv.mkDerivation {
            name = inputfile;
            src = ./.;
            buildPhase = ''
              mkdir -p "$out"
              ${pkgs.typst}/bin/typst compile \
                --font-path "${font-path}" \
                --ignore-system-fonts \
                --package-path "${typstPackage}" \
                "${inputfile}" "$out/${outputfile}"
            '';
            dontInstall = true;
          };
        all-compile = pkgs.stdenv.mkDerivation {
          name = "Build all typst and pages";
          src = ./.;
          buildPhase = ''
            mkdir -p "$out"
            ${pkgs.findutils}/bin/find . -name "*.typ" -maxdepth 1 \
              | xargs -I{} basename {} .typ \
              | xargs -I{} \
                ${pkgs.typst}/bin/typst compile \
                  --font-path "${font-path}" \
                  --ignore-system-fonts \
                  --package-path "${typstPackage}" \
                  "{}.typ" "$out/{}.pdf"
            ${pkgs.findutils}/bin/find "$out" -name "*.pdf" -maxdepth 1 \
              | xargs -I{} basename {} .pdf \
              | xargs -I{} sh -c "echo '<embed src=\"./{}.pdf\" width=\"100%\" height=\"100%\" type=\"application/pdf\">' > $out/{}.html"
            echo '<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><title>slides</title><link rel="stylesheet" href="https://classless.de/classless.css"></head><body><h1>Slides</h1><ul>' > "$out/index.html"
            ${pkgs.findutils}/bin/find "$out" -name "*.pdf" -maxdepth 1 \
              | xargs -I{} basename {} .pdf \
              | xargs -I{} echo '<li><a href="./{}.html">{}</a></li>' >> $out/index.html
            echo '</ul></body></html>' >> "$out/index.html"
          '';
          dontInstall = true;
        };
        runAs =
          name: runtimeInputs: text:
          let
            program = pkgs.writeShellApplication {
              inherit name runtimeInputs text;
            };
          in
          {
            type = "app";
            program = "${program}/bin/${name}";
          };
        devPackages = rec {
          # keep-sorted start block=yes
          actions = with pkgs; [
            actionlint
            ghalint
            zizmor
          ];
          typst_ = with pkgs; [
            typst
            typstyle
            tinymist
          ];
          # keep-sorted end
          default = actions ++ [ treefmt.config.build.wrapper ];
        };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            settings.global.excludes = [ ];
            programs = {
              # keep-sorted start block=yes
              formatjson5 = {
                enable = true;
                indent = 2;
              };
              keep-sorted.enable = true;
              mdformat.enable = true;
              nixfmt.enable = true;
              taplo.enable = true;
              typstyle.enable = true;
              yamlfmt = {
                enable = true;
                settings = {
                  formatter = {
                    type = "basic";
                    retain_line_breaks_single = true;
                  };
                };
              };
            };
            # keep-sorted end
          }
        );
      in
      {
        # keep-sorted start block=yes
        apps = {
          check-actions =
            ''
              actionlint
              ghalint run
              zizmor .github/workflows .github/actions
            ''
            |> runAs "check-actions" devPackages.actions;
        };
        checks = {
          formatting = treefmt.config.build.check self;
        };
        devShells = {
          default = pkgs.mkShell {
            packages = [
              pkgs.typst
            ];
          };
        };
        formatter = treefmt.config.build.wrapper;
        packages = {
          default = typst-compile "2025-10-18_nix-meetup-4.typ" "main.pdf";
          all = all-compile;
        };
        # keep-sorted end
      }
    );
}
