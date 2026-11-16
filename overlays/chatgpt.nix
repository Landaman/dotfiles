final: prev:
let
  linuxVersion = "26.1111.71704";
  sources = {
    aarch64-darwin = rec {
      version = "26.1111.71704";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-DHkNirWEJVOf4dhEBmrLi4BBWqGaXEbYlAmBURLoE00=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-8FUN7h+ZEn01etdgrvc5xVfUm9Z3KNLxBdAKekeA90A=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-Ae73x3yDX34a+5K6HCkXikwZ1sZlc73TuGUg4qv4BqQ=";
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
