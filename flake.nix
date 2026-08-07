{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self
    , nixpkgs
    ,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      graal = pkgs.graalvmPackages.graalvm-ce-musl;
      myCustomApp = pkgs.callPackage ./pkg.nix {};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          graal
          pkgs.scala-next
          pkgs.zsh
          pkgs.uglify-js
        ];
        shellHook = ''
          export JAVA_HOME="${graal}"
          export PATH="$PATH:$JAVA_HOME/bin"
        '';
      };
      packages.${system} = rec {
        my-app = myCustomApp;
        default = my-app;
      };
      apps.${system} = rec {
        server = {
          type = "app";
          program = "${myCustomApp}/bin/my-app";
        };
        default = server;
      };
    };
}
