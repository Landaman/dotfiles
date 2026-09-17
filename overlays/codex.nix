final: prev:
let
  version = "0.153.4";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-lHiDj5SodaM3mh8goMm6esfejeAT+Y3JJWrRnyj6sJo=";
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
      hash = "sha256-6IAX/SFSSgSKKFxKsUXoZ9nNQaHJ+EjZ5a4bJwyDdF0=";
    };
  });
}
