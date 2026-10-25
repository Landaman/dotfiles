final: prev:
let
  version = "2.1.310";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude.zst";
            checksum = "0252ecc7c918fccc5a68d6f25a80c4579c4cf99fad8b315228236c2ee9c3f4af";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "ad34932dfad2bd67c328b9358acaac7c998e8113dc065dd328958b984a73fe27";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "9314f28f679546a97813f2914c4fb60a190801ef782805f47bf197317cc4ffd2";
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
