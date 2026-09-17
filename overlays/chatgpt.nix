final: prev:
let
  version = "26.803.81509";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-NMfmKWeK1dY6Y57GlKW4O4X04b18Ie4qvP77sEEJW5w=";
    };
  };
}
