{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
  dotnetCorePackages,
}:
stdenvNoCC.mkDerivation rec {
  pname = "dotrush";
  version = "2026.10";
  src = fetchurl {
    url = "https://github.com/JaneySprings/DotRush/releases/download/${version}/DotRush.Bundle.LanguageServer.zip";
    hash = "sha256:c5ad6defa83f6d48364da4fd4c2c9bd39d00c1256e9bd9729f2a4178111834ae";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/dotrush
    unzip $src -d $out/lib/dotrush
    makeWrapper ${dotnetCorePackages.sdk_10_0}/bin/dotnet $out/bin/dotrush \
      --add-flags "$out/lib/dotrush/DotRush.dll" \
      --set DOTNET_ROOT ${dotnetCorePackages.sdk_10_0}/share/dotnet
    runHook postInstall
  '';

  meta = {
    description = "DotRush C# language server";
    homepage = "https://github.com/JaneySprings/DotRush";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "dotrush";
  };
}
