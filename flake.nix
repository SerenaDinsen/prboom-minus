{
  description = "PRBoom+ 2.6.66 build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [
        pkgs.SDL2
        pkgs.cmake
        pkgs.makeWrapper  # optional helper
        pkgs.gcc  # or clang
      ];
      shellHook = ''
        echo "devShell for PRBoom+ ready. cmake and sdl2 available."
      '';
    };

    packages.${system}.prboom-plus = pkgs.stdenv.mkDerivation {
      pname = "prboom-plus";
      version = "2.6.66";

      src = pkgs.fetchFromGitHub {
        owner = "SerenaDinsen";
        repo = "prboom-minus";
        rev = "master";
        sha256 = "sha256-/3QOb5kFV2Ppz5t5DZ3SHLdFvE1r72Pfgv+y61M+ho8=";
      };
      sourceRoot = "source/prboom2";
      nativeBuildInputs = [ pkgs.cmake pkgs.makeWrapper ];
      buildInputs = [ pkgs.SDL2 ];

      cmakeFlags = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_INSTALL_PREFIX=$out"
      ];

      # Optional: Workaround flags for modern compilers (as noted in Arch AUR)
      # configurePhase = ''
      #   cmake -Wno-dev -DCMAKE_C_FLAGS="-Wno-error=incompatible-pointer-types" \
      #     ${cmakeFlags[@]} "$src"
      # '';
      enableParallelBuilding = true;
      installPhase = "make install";

      meta = with pkgs.lib; {
        description = "PRBoom+ Doom source port (version 2.6.66)";
        license = licenses.gpl2;
        homepage = "https://github.com/coelckers/prboom-plus";
        maintainers = with maintainers; [ ];
      };
    };
  };
}

