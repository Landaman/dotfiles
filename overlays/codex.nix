final: prev:
let
  version = "0.166.0";
  src = final.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    hash = "sha256-4zxnVT9PxIj0+ULQ4LSA46GmvfyNTueZ+BsQ2SZwk1I=";
  };
in
{
  codex = prev.codex.overrideAttrs (finalAttrs: {
    inherit version;
    inherit src;
    buildCommit = "6ff1e1ca3b30fc8b914720681fcf5fe62e95f856";

    cargoHash = "sha256-3CHn33C1SSX+W0juZik3r8CVoYGoyNlk5mDICwVEcbY=";
  });
}
