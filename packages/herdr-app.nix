{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "herdr-app";
  version = "0.1.14";
  coreVersion = "0.1.19";

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${version}/Herdr.dmg";
    hash = "sha256-Jso6s5x2wBCWch6E2TQsugvLGzN+L1x5VurIoHuZKJU=";
  };
  core = fetchurl {
    url = "https://releases.herdr.dev/core/${coreVersion}/herdr-core-macos-aarch64.tar.gz";
    hash = "sha256-UzjZAK2tttJzucjpcCckfbMXnM/+3hCheTNY8W4I1oM=";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"

    cp -R Herdr.app "$out/Applications/"
    ln -s "$out/Applications/Herdr.app/Contents/MacOS/Herdr" "$out/bin/herdr-app"

    tar -xzf "$core" -C "$out/bin" herdr-core
    ln -s herdr-core "$out/bin/hc"

    runHook postInstall
  '';
  dontFixup = true;

  meta = {
    description = "Desktop app for terminals and coding agents";
    homepage = "https://github.com/herdrdev/herdr-app";
    license = lib.licenses.asl20;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "herdr-app";
  };
}
