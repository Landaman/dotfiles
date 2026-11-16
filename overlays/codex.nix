final: prev:
let
  version = "0.170.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-iJkH0tknBE/+bAWWKDiG9rLfuj0KDcSHDa91Offd7R8=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "29eb79e9866b3262a777fdf8195c1b9e63684c91";

    cargoHash = "sha256-dovquz74E13RYwAGuXRcyhvVAeSDXiqserw9inujf+c=";
  });
}
