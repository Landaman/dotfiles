final: prev:
let
  version = "0.159.2";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-fYzQEit5MxsEZw/UaISMbEIsy5iaAcqb7ElEOq9eVgs=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;

    cargoDeps = final.rustPlatform.fetchCargoVendor {
      pname = "codex";
      inherit version src;
      sourceRoot = "${src.name}/codex-rs";
      hash = "sha256-U20V8MkGJZd+qTOQETzqB25QJPYxJGV89LiR1kToW7A=";
    };
  });
}
