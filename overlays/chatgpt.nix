final: prev:
let
  linuxVersion = "26.1023.51421";
  sources = {
    aarch64-darwin = rec {
      version = "26.1023.51421";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT.dmg";
      hash = "sha256-7W1VhRRXMiIsZ1buiwfgR7knR0M7SCYpmvuSl4cWgMY=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-50eNhPKTjdNz+mHFKw8gCwfWEOSJRwUr2K10dpt/0/s=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-RITcK1T8CXi+sjuNjXF0lOTgtPvqsKh2c5EF5QtE3lo=";
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
        nativeBuildInputs =
          old.nativeBuildInputs ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [ final.undmg ];
      });
}
