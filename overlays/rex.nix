{ rex }:
final: _prev:
let
  package = rex.packages.${final.stdenv.hostPlatform.system}.default;
  app = final.stdenvNoCC.mkDerivation rec {
    pname = "${package.pname}-app";
    version = "0.1.0-1932";

    src = final.fetchurl {
      url = "https://blob.superlogical.com/public/rex-app/snapshot/Rex-${version}.dmg";
      hash = "sha256-8kPRF3G5NrsenIllwM2G+4Lw3Q2Kij0wCIRpkH/ZESA=";
    };

    nativeBuildInputs = [ final.undmg ];
    sourceRoot = ".";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/Applications"
      cp -R "Rex Beta.app" "$out/Applications/"
      runHook postInstall
    '';
    dontFixup = true;

    meta = package.meta // {
      platforms = final.lib.platforms.darwin;
    };
  };
in
{
  rex = final.symlinkJoin {
    inherit (package) pname meta;
    version = if final.stdenv.hostPlatform.isDarwin then app.version else package.version;
    paths = [ (if final.stdenv.hostPlatform.isDarwin then app else package) ];
    nativeBuildInputs = [ final.installShellFiles ];
    postBuild = ''
      ${final.lib.optionalString final.stdenv.hostPlatform.isDarwin ''
        mkdir -p "$out/bin" "$out/share"
        ln -s "$out/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" "$out/bin/rex"
        ln -s ${package}/share/terminfo "$out/share/terminfo"
        ln -s ${package}/share/rex "$out/share/rex"
      ''}
      installShellCompletion --cmd rex \
        --bash <("$out/bin/rex" completion bash) \
        --fish <("$out/bin/rex" completion fish) \
        --zsh <("$out/bin/rex" completion zsh)
    '';
  };
}
