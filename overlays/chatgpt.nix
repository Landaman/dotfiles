final: prev:
let
  version = "26.1021.31345";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-KvzVjgSEp2R5zKIxdOCFEnqdnmNGa3VznraCWl/2E/Q=";
    };
  };
}
