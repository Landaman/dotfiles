{
  lib,
  stdenv,
  fontconfig,
  fetchurl,
  undmg,
  autoPatchelfHook,
  makeDesktopItem,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  libGL,
}:
let
  inherit (stdenv.hostPlatform) system;

  version = "0.1.14";
  appHashes = {
    x86_64-linux = "sha256-R1o4P49DnjGRqGY1tcEobOTf0tn83x58vf3Wxxdvj/M=";
    aarch64-linux = "sha256-MKQxzpXBc1bv6K/tUMTq+IiNg+9FrNmqkRCU1RcH0Ac=";
    aarch64-darwin = "sha256-Jso6s5x2wBCWch6E2TQsugvLGzN+L1x5VurIoHuZKJU=";
  };
  coreVersion = "0.1.19";
  coreHashes = {
    x86_64-linux = "sha256-Stz7Qj1S8kxcxKHizS/K0fYtKLt3h2rEcsKQgqPqpCQ=";
    aarch64-linux = "sha256-+Vw0/XF37ViAfXT+TueLs9xz6zfyHGlJYGQACiGryxA=";
    aarch64-darwin = "sha256-UzjZAK2tttJzucjpcCckfbMXnM/+3hCheTNY8W4I1oM=";
  };

  linux = stdenv.hostPlatform.isLinux;
  arch = stdenv.hostPlatform.parsed.cpu.name;

  desktopItem = makeDesktopItem {
    name = "herdr-app";
    desktopName = "Herdr";
    comment = "Terminals and coding agents that keep running";
    exec = "herdr-app";
    icon = "herdr-app";
    categories = [ "Development" ];
    startupWMClass = "herdr-app";
  };
in
stdenv.mkDerivation {
  pname = "herdr-app";
  inherit version coreVersion;

  src = fetchurl {
    url =
      if linux then
        "https://releases.herdr.dev/app/${version}/herdr-app-linux-${arch}.tar.gz"
      else
        "https://releases.herdr.dev/app/${version}/Herdr.dmg";
    hash = appHashes.${system};
  };
  core = fetchurl {
    url = "https://releases.herdr.dev/core/${coreVersion}/herdr-core-${
      if linux then "linux" else "macos"
    }-${arch}.tar.gz";
    hash = coreHashes.${system};
  };

  nativeBuildInputs = if linux then [ autoPatchelfHook ] else [ undmg ];
  buildInputs = lib.optionals linux [
    fontconfig
    stdenv.cc.cc.lib
    libxcb
    libxkbcommon
  ];
  # Keep libraries loaded at runtime available without a launcher wrapper
  runtimeDependencies = lib.optionals linux [
    wayland
    vulkan-loader
    libGL
  ];
  sourceRoot = if linux then "herdr-app" else ".";
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    ${lib.optionalString linux ''
      install -Dm755 herdr-app "$out/bin/herdr-app"
      install -Dm644 herdr-app.svg "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"
      mkdir -p "$out/share/applications"
      ln -s ${desktopItem}/share/applications/* "$out/share/applications/"
    ''}
    ${lib.optionalString (!linux) ''
      mkdir -p "$out/Applications"
      cp -R Herdr.app "$out/Applications/"
      ln -s "$out/Applications/Herdr.app/Contents/MacOS/Herdr" "$out/bin/herdr-app"
    ''}
    tar -xzf "$core" -C "$out/bin" herdr-core
    ln -s herdr-core "$out/bin/hc"
    runHook postInstall
  '';
  # Preserve macOS code signatures; Linux needs fixup to patch the loader and library paths
  dontFixup = !linux;

  meta = {
    description = "Desktop app for terminals and coding agents";
    homepage = "https://github.com/herdrdev/herdr-app";
    license = lib.licenses.asl20;
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    mainProgram = "herdr-app";
  };
}
