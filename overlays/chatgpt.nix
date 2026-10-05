final: prev:
let
  version = "26.930.51102";
in
{
  chatgpt = prev.chatgpt.overrideAttrs {
    inherit version;

    src = final.fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-cAHfKT/UeLKk4ti19Oo6rkOi4h0WiWAlay8xrE7kP28=";
    };
  };
}
