final: prev:
let
  version = "0.160.1";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-9oXMysQ+v4txGIhPsgh45xAAqWYglZjhdS50uxMPHz4=";
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
      hash = "sha256-DMRbIOynO0wGXjBxaXZJNKorD9YQv3fAoRTZ4iZEIE4=";
    };
  });
}
