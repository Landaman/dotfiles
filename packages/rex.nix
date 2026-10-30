{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  undmg,
}:
stdenvNoCC.mkDerivation rec {
  pname = "rex";
  version = "0.1.0-1652";

  src = fetchurl {
    url = "https://blob.superlogical.com/public/rex-app/snapshot/Rex-${version}.dmg";
    hash = "sha256-JjLPnEF6R64k+IAok56SouNB99tFkfM3CEGMfi2ClQ8=";
  };

  nativeBuildInputs = [
    installShellFiles
    undmg
  ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R "Rex Beta.app" "$out/Applications/"

    mkdir -p "$out/bin"
    ln -s "$out/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" "$out/bin/rex"

    rex="Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
    installShellCompletion --cmd rex \
      --bash <("$rex" completion bash) \
      --fish <("$rex" completion fish) \
      --zsh <("$rex" completion zsh)
    runHook postInstall
  '';

  dontFixup = true;

  meta = {
    description = "The multiplexer for all work";
    homepage = "https://www.superlogical.com/rex";
    platforms = lib.platforms.darwin;
  };
}
