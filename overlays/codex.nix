final: prev:
let
  version = "0.157.1";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-HuNL5VGd2LenhbCdcz0i8b6lRw3sicwXytyfXgCgy88=";
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
      hash = "sha256-Mp4chq9QuQB19FrOZBhmUtPrDoEpZZna79+MZs9rGUo=";
    };
  });
}
