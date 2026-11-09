{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  autoPatchelfHook,
  stdenv,
  icu,
  openssl,
  zlib,
  lttng-ust_2_12,
}:
let
  sources = {
    aarch64-linux = {
      runtime = "linux-arm64";
      hash = "sha256-Ud4yWstexZ2JDz/4j+d+gmUOGIrNFCEYMEsZQTM6n7M=";
    };
    x86_64-linux = {
      runtime = "linux-x64";
      hash = "sha256-dn4H+HqcQ5uCZJ7iGb08dBxKOIMs3UcQ25TT8Xokm5E=";
    };
    aarch64-darwin = {
      runtime = "osx-arm64";
      hash = "sha256-05/Tlr3Gohe7VeTL7LTdgC94gHKowj9QKMfVyhK2Tu0=";
    };
    x86_64-darwin = {
      runtime = "osx-x64";
      hash = "sha256-kuMfZpCUnZxJddVq5kYD0hc4ztKKFhlxaVi+LVkvDg0=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation rec {
  pname = "clrdbg";
  version = "18.1.0";
  src = fetchurl {
    url = "https://github.com/JaneySprings/clrdbg/releases/download/${version}/clrdbg_${source.runtime}.zip";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (lib.getLib stdenv.cc.cc)
    zlib
    openssl
    icu
    lttng-ust_2_12
  ];
  # CoreCLR loads these libraries dynamically rather than through ELF dependencies.
  runtimeDependencies = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    (lib.getLib openssl)
    (lib.getLib icu)
  ];
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/clrdbg
    unzip $src -d $out/lib/clrdbg
    chmod +x $out/lib/clrdbg/clrdbg
    makeWrapper $out/lib/clrdbg/clrdbg $out/bin/clrdbg
    runHook postInstall
  '';

  meta = {
    description = ".NET debug adapter used by DotRush";
    homepage = "https://github.com/JaneySprings/clrdbg";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "clrdbg";
  };
}
