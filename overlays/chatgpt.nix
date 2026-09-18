final: prev:
let
  version = "26.915.31029";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-NkZ257h9T1Kx5SwCCu1OLsgSmAy94VZD9bOcyRv7H3c=";
    };
  };
}
