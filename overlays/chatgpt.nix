final: prev:
let
  linuxVersion = "26.1027.30824";
  sources = {
    aarch64-darwin = rec {
      version = "26.1027.30824";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-eQGLzcwUGQLZoOYZUOwgf3GVGUHbQWX4oNwtyPDcyIM=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-tkjiu8HEMO+8dHDGnmRE98bT8yyYqKq1qiA/LCnT3gU=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-ThOaRPfJF6ZD8t0BStMimN0wrsbTJNMjUksZD3ZnaEw=";
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
