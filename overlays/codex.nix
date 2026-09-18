final: prev:
let
  version = "0.155.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-O+onwNd5YdE/KUJNBeQxBfK5JohzXenE4eOwejxFptc=";
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
