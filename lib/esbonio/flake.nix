{
  description = "The Esbonio language server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # pytest-lsp.url = "github:swyddfa/lsp-devtools?dir=lib/pytest-lsp";
    lsp-devtools.url = "path:/var/home/alex/Projects/lsp-devtools";
    lsp-devtools.inputs.nixpkgs.follows = "nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, lsp-devtools, utils }:

    let
      esbonio-overlay = import ./nix/esbonio-overlay.nix;

      buildMatrix = {
        py = [ "38" "39" "310" "311" ];
      };

      applyMatrix = matrix: f:
        builtins.foldl' (x: y: x // y) {}
          (builtins.map f (nixpkgs.lib.cartesianProductOfSets matrix));
    in {

      overlays.default = self: super:
        nixpkgs.lib.composeManyExtensions [ lsp-devtools.overlays.default esbonio-overlay ] self super;

      devShells = utils.lib.eachDefaultSystemMap (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
        in
          applyMatrix buildMatrix ({ py, ...}: {

            "py${py}-esbonio" = pkgs.mkShell {
                name = "py${py}-esbonio";

                shellHook = ''
                  export PYTHONPATH="./:$PYTHONPATH"
                '';

                packages = with pkgs."python${py}Packages"; [
                  # Runtime deps
                  docutils
                  platformdirs
                  pygls
                  websockets

                  # Test deps
                  pytest-lsp
                  pytest-timeout
                ];
            };

            "py${py}-sphinx" = pkgs.mkShell {
              name = "py${py}-sphinx";

              shellHook = ''
                export PYTHONPATH="./:$PYTHONPATH"
              '';

              packages = with pkgs."python${py}Packages"; [
                # Runtime deps
                platformdirs
                pygls
                sphinx

                # Test deps
                pytest-lsp
                pytest-timeout
              ];

            };
          })
    );
  };
}
