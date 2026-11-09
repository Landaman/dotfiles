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
  version = "2026.11";
  src = fetchurl {
    url = "https://github.com/JaneySprings/DotRush/releases/download/${version}/DotRush.Bundle.LanguageServer.zip";
    hash = "sha256-YnCzsENHIeAr4D7BOGPn4gKzK9UTYBvQDgmClX9e31k=";
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
