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
}:
let
  sources = {
    aarch64-linux = {
      runtime = "linux-arm64";
      hash = "sha256:ea468edd899b0b1560f843b0ebc38b3921be757a1e3ba57239f66f042b5971c0";
    };
    x86_64-linux = {
      runtime = "linux-x64";
      hash = "sha256:6de5eda5b48dddba3b60773d58019e5353cb3a9b3646031ee8ff3c154f996038";
    };
    aarch64-darwin = {
      runtime = "osx-arm64";
      hash = "sha256:c60a0c5d65971f638b3690211568550eaec30c1dd0a2953504b6dd493700216a";
    };
    x86_64-darwin = {
      runtime = "osx-x64";
      hash = "sha256:7393d88770565b8268c154c5a6d7e6c0d76482fa69af64196c811b1e1261fdab";
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
