final: prev:
let
  version = "0.167.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-9BVM0mUQ+F9QpqvnG+7x4ZXYaNTclcGLtF5DzEU5Zzg=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "086ccc833bc9cf01024ad2dd6af7dbd421b6bf9a";

    cargoHash = "sha256-Dqo9nMfbkTcyT+S79U2JdXpnxwrN0fQjjMlG055jvJE=";
  });
}
