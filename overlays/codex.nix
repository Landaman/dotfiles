final: prev:
let
  version = "0.167.1";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-S63Qd9OGCACz1EK/IzH6LGsZxMovk0UBkOKtv/jnQ+I=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "0a94398fa60c4fac0e7659e4213a0a36e613dd46";

    cargoHash = "sha256-Dqo9nMfbkTcyT+S79U2JdXpnxwrN0fQjjMlG055jvJE=";
  });
}
