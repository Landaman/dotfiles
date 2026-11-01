{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "herdr-app";
  version = "0.1.11";
  coreVersion = "0.1.16";

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${version}/Herdr.dmg";
    hash = "sha256-6RggRhLQrQJm9Has3PeyF8NNDX4cis4io3st8r8g6vs=";
  };
  core = fetchurl {
    url = "https://releases.herdr.dev/core/${coreVersion}/herdr-core-macos-aarch64.tar.gz";
    hash = "sha256-aY2PDET05LFf7BdNUqOdV6AUz9ca3e1EtToHU7Rp0P0=";
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
