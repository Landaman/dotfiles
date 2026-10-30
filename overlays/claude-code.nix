final: prev:
let
  version = "2.1.314";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-oj7lymRafjQvCWBGTJSLrrfEIYiUuiWDbaEsKJraVso=";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-WtQtCPROAtVpIsqC2I22OI6TVkqPwD/vAuQnmyMgQhQ=";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "sha256-6Mb5Y6VBepPrGajbcPRgnAOdgnQmEglx0u/zTpDHBLM=";
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
