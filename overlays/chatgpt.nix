final: prev:
let
  linuxVersion = "26.1117.41037";
  sources = {
    aarch64-darwin = rec {
      version = "26.1117.41037";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-vApC0Bqb3t4cHCuHYVGoGFYNax6vH0WuQC09IinDQiA=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-cUFG6cZnsmob1OV2M8VEM0qe1Hw5mYm/2Yz3ZBQL3FM=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-gw4lG2ykrUX+aQQSenkOjwD3wm7UyAOUc/cyPHxOJpI=";
    };
  };
  source = sources.${final.stdenv.hostPlatform.system} or null;
in
{
  chatgpt =
    if source == null then
      prev.chatgpt
    else
      prev.chatgpt.overrideAttrs (
        old:
        {
          inherit (source) version;
          src = final.fetchurl (removeAttrs source [ "version" ]);
        }
        // final.lib.optionalAttrs final.stdenv.hostPlatform.isLinux {
          # Use util-linux flock for the launcher's file descriptor locks
          passthru = old.passthru // {
            launcher = old.passthru.launcher.override { flock = final.util-linux; };
          };
        }
      );
}
