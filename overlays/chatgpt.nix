final: prev:
let
  version = "26.928.20755";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-rBKevy6Qhpbc5EnjNZLtwWuQsXP0VCJxSN0Q352OwQA=";
    };
  };
}
