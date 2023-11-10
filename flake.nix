{
  description = "A minimal Nix flake for libbpf-bootstrap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        defaultPackage = pkgs.stdenv.mkDerivation {
	  name = "libbpf-bootstrap";
	  src = self;
          buildInputs = with pkgs; [
            clang
            llvmPackages.libclang
            llvmPackages.stdenv.cc.cc.lib
	    llvmPackages.llvm
            zlib
	    elfutils
            pkg-config
            libbpf
	    rustc
	    cargo
	    bpftools
          ];

	  buildPhase = ''
            export LIBBPF_LIB_DIR="${pkgs.libbpf}/lib"
            export LIBBPF_INCLUDE_DIR="${pkgs.libbpf}/include"
            export BPFTOOLS_DIR="${pkgs.bpftools}"
	    make -C examples
	  '';

	  installPhase = "
            mkdir -p $out
	    cp -r examples $out/
	  ";
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            clang
            llvmPackages.libclang
            llvmPackages.stdenv.cc.cc.lib
	    llvmPackages.llvm
            zlib
	    elfutils
            pkg-config
            libbpf
	    rustc
	    cargo
	    bpftools
          ];

          shellHook = ''
            export LIBBPF_LIB_DIR="${pkgs.libbpf}/lib"
            export LIBBPF_INCLUDE_DIR="${pkgs.libbpf}/include"
            export BPFTOOLS_DIR="${pkgs.bpftools}"
          '';
        };
      }
    );
}

