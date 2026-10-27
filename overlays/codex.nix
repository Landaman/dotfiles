final: prev:
let
  version = "0.164.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-iib2+qQcGewC4Ga8cA80sInDJpzdSxDJP0y1DDOouI4=";
  };
in
{
  codex =
    prev.codex.overrideAttrs
      (finalAttrs: {
        inherit version;
        inherit src;
        buildCommit = "6aaac694803004a63c6f393d153c96d22521a6b9";

        cargoHash = "sha256-0N2mEGqEl2ZjWqlbraVCWP0eoITgwmT9uO/1w/1eJno=";
      });
}
