final: prev:
let
  linuxVersion = "26.1021.22027";
  sources = {
    aarch64-darwin = rec {
      version = "26.1021.31345";
      url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${version}.zip";
      hash = "sha256-KvzVjgSEp2R5zKIxdOCFEnqdnmNGa3VznraCWl/2E/Q=";
    };
    aarch64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_arm64.deb";
      hash = "sha256-aN4exEBmhx5Bd7ocp5Pr7muiODl/E8eU5FsUlBwSYfs=";
    };
    x86_64-linux = {
      version = linuxVersion;
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${linuxVersion}_amd64.deb";
      hash = "sha256-6wgxxzTxVPk/jrzw4X0RjaDep9wXN9xhoecURDdb8ZA=";
    };
  };
  source = sources.${final.stdenv.hostPlatform.system} or null;
in
{
  chatgpt =
    if source == null then
      prev.chatgpt
    else
      prev.chatgpt.overrideAttrs {
        inherit (source) version;
        src = final.fetchurl (removeAttrs source [ "version" ]);
      };
}
