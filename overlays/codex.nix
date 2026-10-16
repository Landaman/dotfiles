final: prev:
let
  version = "0.163.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-Fa9dfiGJy+uqSF4A0EM6AQQhhjQdu+jfhKzqXid9PNA=";
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
      hash = "sha256-TG1fDHQCRDDbk+G0NS/9NTouJupq0Zisi4LIJY4SgYw=";
    };
  });
}
