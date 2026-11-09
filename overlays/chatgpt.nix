final: prev:
let
  linuxVersion = "26.1103.60933";
  sources = {
    aarch64-darwin = rec {
      version = "26.1103.60933";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-HWced4Tg43n3KT68/qyCbCopdSTqgGzVXplAaNAZ44g=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-bbGahFWR1QnpuDywqOC0oi3uJ0SNIRwdH6ik+5LtzF0=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-B0bpuldRgvXb4yYXuCpkXrk61XyliOWpNYaVprZa7nE=";
    };
  };
  source = sources.${final.stdenv.hostPlatform.system} or null;
in
{
  chatgpt =
    if source == null then
      prev.chatgpt
    else
      prev.chatgpt.overrideAttrs (old: {
        inherit (source) version;
        src = final.fetchurl (removeAttrs source [ "version" ]);
      });
}
