{
  description = "Flooded - fork of wideriver tiling window manager for the river wayland compositor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Build inputs
      buildInputs = with pkgs; [
        wayland
        wayland-protocols
      ];
      
      nativeBuildInputs = with pkgs; [
        pkg-config
        wayland-scanner
      ];
      
      # Build the package
      flooded = pkgs.stdenv.mkDerivation {
        pname = "flooded";
        version = "0.1.0";
        
        src = self;
        
        nativeBuildInputs = nativeBuildInputs;
        buildInputs = buildInputs;
        
        # Set build environment variables to match the Makefile
        preBuild = ''
          export PREFIX=$out
          export VERSION="0.1.0"
          export RIVER_LAYOUT_V3_VERSION=2
          export INCS="-Iinc -Ipro -Ilib/col/inc"
          export CPPFLAGS="$INCS -D_GNU_SOURCE -DVERSION=\"$VERSION\" -DRIVER_LAYOUT_V3_VERSION=$RIVER_LAYOUT_V3_VERSION"
          export CFLAGS="-O3 -pedantic -Wall -Wextra -Werror -Wimplicit-fallthrough -Wno-unused-parameter -Wno-format-zero-length -g -std=gnu17 -Wold-style-definition -Wstrict-prototypes"
          export CC=gcc
        '';
        
        # Use the existing Makefile
        buildPhase = ''
          runHook preBuild
          make
          runHook postBuild
        '';
        
        installPhase = ''
          runHook preInstall
          make install
          runHook postInstall
        '';
        
        # Meta information
        meta = with pkgs.lib; {
          description = "Tiling window manager for the river wayland compositor, inspired by dwm and xmonad";
          homepage = "https://github.com/alex-courtis/flooded";
          license = licenses.mit;
          maintainers = [ ];
          platforms = platforms.linux;
          mainProgram = "flooded";
        };
      };
      
    in
    {
      packages.${system} = {
        default = flooded;
        flooded = flooded;
      };
      
      
      # Formatter for the flake
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}