final: prev:
let
  version = "2.1.312";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude.zst";
            checksum = "7d759495d011057b6e8b8ee911c5be3cd36e9491c71a4ab194a425cdb1418073";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "863ee1d2a91a39ee22fa13322582e4c3fb45bfb4739b22ec7e396dde694d8581";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "6fb9e329947c003740be888f98db1aecaa238d6c7d9ceef8581eb71d5a59480b";
          };
        };
      };
    }).overrideAttrs
      (old: {
        # Keep public roots alongside the locally trusted certificates returned on macOS
        installPhase =
          if prev.stdenv.hostPlatform.isDarwin then
            builtins.replaceStrings
              [ "--set-default CLAUDE_CODE_CERT_STORE system" ]
              [ "--set-default CLAUDE_CODE_CERT_STORE bundled,system" ]
              old.installPhase
          else
            old.installPhase;
      });
}
