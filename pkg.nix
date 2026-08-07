{ lib, stdenv, pkgs }:
let
  deps = stdenv.mkDerivation {
    pname = "my-app-deps";
    version = "0.0.1";
    src = ./.;

    # cacert for SSL from Maven Central
    nativeBuildInputs = with pkgs; [ scala-next cacert ];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-8LmBp90t7X86tfTAy3JKuXnIcgc24ihluOQh8f0FbY4=";

    buildPhase = ''
      export COURSIER_CACHE=$(pwd)/coursier-cache
      scala compile main.js.scala
      scala compile main.jvm.scala
    '';

    installPhase = ''
      cp -r $COURSIER_CACHE $out
    '';
  };
in

stdenv.mkDerivation {
  pname = "my-app";
  version = "0.0.1";
  src = ./.;

  nativeBuildInputs = with pkgs; [
    scala-next
    uglify-js
    graalvmPackages.graalvm-ce-musl
  ];

  buildPhase = ''
    # config
    export COURSIER_CACHE=${deps}
    export COURSIER_MODE=offline
    scala config power true

    # front
    mkdir -p static-resources
    scala package main.js.scala --js -o app.js --js-mode release
    uglifyjs app.js > static-resources/bundle.js && rm app.js

    # back
    scala package main.jvm.scala --resource-dirs static-resources -f -o app.jar --assembly --preamble=false
    native-image \
          --static \
          --libc=musl \
          --verbose \
          --report-unsupported-elements-at-runtime \
          --no-fallback \
          --initialize-at-run-time=io.netty \
          -jar app.jar \
          my-app
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp my-app $out/bin/
  '';
}
