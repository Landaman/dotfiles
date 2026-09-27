final: prev:
let
  version = "26.924.22138";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-fPlWmxFqMq9hpqtOmXlGZ3S23I6dvPcCZFlqGuLf1X0=";
    };
  };
}
