final: prev:
let
  version = "2.1.322";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-pULFFKB9DKCUCN8rhgi+bFJDifIyMn0Zayb1tBBWuBM=";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-LGvh6fyh3LiU5H4RZy9EMvTPioefXlMCia0wgCEAxdc=";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "sha256-m7dVi9mSykV+ZFi/FoZXL3oxVrgzHdhEM5Hb/lkMHu0=";
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
