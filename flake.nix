{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    # Using old version of nixpkgs for mongo due to https://github.com/NixOS/nixpkgs/issues/171928
    # Waiting on PR https://github.com/NixOS/nixpkgs/pull/172009
    nixpkgs-old.url = "github:NixOS/nixpkgs/a7cf9372e97725eaa6da1e72698af9d23a3ea083";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-old
    , nixpkgs-unstable
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-old = import nixpkgs-old {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      in
      rec {
        inherit pkgs;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs-16_x
            nodePackages.pm2
            # pkgs-old.mongodb-5_0
            jdk11_headless
            sops
          ];
          TZ = "UTC";
          PRISMA_QUERY_ENGINE_BINARY = "${pkgs-unstable.prisma-engines}/bin/query-engine";
          PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs-unstable.prisma-engines}/lib/libquery_engine.node";
          PRISMA_MIGRATION_ENGINE_BINARY = "${pkgs-unstable.prisma-engines}/bin/migration-engine";
          PRISMA_INTROSPECTION_ENGINE_BINARY = "${pkgs-unstable.prisma-engines}/bin/introspection-engine";
          PRISMA_FMT_BINARY = "${pkgs-unstable.prisma-engines}/bin/prisma-fmt";
          # MONGOMS_SYSTEM_BINARY_VERSION_CHECK = "false";
          # MONGOMS_SYSTEM_BINARY = "${pkgs-old.mongodb-5_0}/bin/mongod";
          shellHook = with pkgs; ''
            export PATH=$(pwd)/node_modules/.bin:$PATH
          '';
        };
      });
}
