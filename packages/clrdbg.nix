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
      hash = "sha256-2Sn+a9Ufwve7IznYSzFSJhMOxX1MsG6D8zcF7HWH6Ds=";
    };
    x86_64-linux = {
      runtime = "linux-x64";
      hash = "sha256-Fgzl/gmNiIwSJZ3TxHAyexCI0sRig8hYeiSoP0aeeWM=";
    };
    aarch64-darwin = {
      runtime = "osx-arm64";
      hash = "sha256-XtBqO4is3ZR01/knXPb+ozwe23Qh8v98T39MM0aFRfY=";
    };
    x86_64-darwin = {
      runtime = "osx-x64";
      hash = "sha256-OweKYN2ZsdH9KQXpZRGfPZkTFQ+rfpkMrdzf/QsBfm0=";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation rec {
  pname = "clrdbg";
  version = "18.0.0";
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
