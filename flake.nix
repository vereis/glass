{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
        let
          pkgs = import nixpkgs { inherit system; };

          # `sha256` can be programmatically obtained via running the following:
          # `nix-prefetch-url --unpack https://github.com/elixir-lang/elixir/archive/v${version}.tar.gz`
          elixir_1_15_7 = (pkgs.beam.packagesWith pkgs.erlangR26).elixir_1_15.override {
            version = "1.15.7";
            sha256 = "0yfp16fm8v0796f1rf1m2r0m2nmgj3qr7478483yp1x5rk4xjrz8";
          };
        in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [ elixir_1_15_7 ];
            env = { ERL_AFLAGS = "-kernel shell_history enabled"; };
          };
        }
    );
}
