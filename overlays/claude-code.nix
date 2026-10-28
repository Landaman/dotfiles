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
            checksum = "sha256-fXWUldARBXtui47pEcW+PNNulJHHGkqxlKQlzbFBgHM=";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-hj7h0qkaOe4i+hMyJYLkw/tFv7RzmyLsfjlt3mlNhYE=";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "sha256-b7njKZR8ADdAvoiPmNsa7KojjWx9nO74WB63HVpZSAs=";
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
