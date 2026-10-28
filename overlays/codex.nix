final: prev:
let
  version = "0.165.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-b9PpwNQeZsJIN4wbGA3FLfWAKd2EDMN5E/zj/Y62/vk=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "360319d8dee62d87e2d59fc0c21805d79519cfed";

    cargoHash = "sha256-KKC/uHE2RWq0U7FmXA+TKTlFf/d8vYe6/G8gl78bW+g=";
  });
}
