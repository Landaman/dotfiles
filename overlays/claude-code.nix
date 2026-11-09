final: prev:
let
  version = "2.1.319";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-gqWWmLzsiiB0y3usvRMM9VfBA1I/GkUK0ROrjdh3io4=";
          };
          linux-arm64 = {
            binary = "claude.zst";
            checksum = "sha256-/dimhssNS7pvKlnV8SDel2tdXvl23wKeSLgC3RU4ETA=";
          };
          linux-x64 = {
            binary = "claude.zst";
            checksum = "sha256-mXfZAwN0BBWvdryAhTazRiDQswt/CLCBNgNomHU3LqA=";
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
