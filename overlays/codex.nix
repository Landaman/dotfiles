final: prev:
let
  version = "0.171.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-Q0fxlAU4oJZOHJtsVVaJJ28XuupzpCYGO4IKn9TAwl0=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "ccf9be8cc458bd6b8336fe84d68d8893f2691a5e";

    cargoHash = "sha256-57GGsc4vgmQnnOXOPf2QaqrW8+02cpc/zotb8Y+rRio=";
  });
}
