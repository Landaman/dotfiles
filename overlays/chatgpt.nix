final: prev:
let
  version = "26.1002.52244";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-Pxhv1tisEm6dZpNs78++EWQA4PGfOa4WfiUXAjC4VMU=";
    };
  };
}
