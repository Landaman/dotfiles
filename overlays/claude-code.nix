final: prev:
let
  version = "2.1.328";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude";
            checksum = "sha256-6FVHGQ74zZgwM7phsXGUBFpv6gADXaNJ7+q+2GutrMk=";
          };
          linux-arm64 = {
            binary = "claude";
            checksum = "sha256-MH+LraJ7N9t1U/rHXoYATj2/9akx/8YRtU/nEM4etSE=";
          };
          linux-x64 = {
            binary = "claude";
            checksum = "sha256-qYLTgDC5fnUISK3Sy7LfbZpw1VRKIsqbIWo0m6JYZeg=";
          };
        };
      };
    }).overrideAttrs
      (old: {
        # Keep public roots alongside the locally trusted certificates returned on macOS
        installPhase =
          builtins.replaceStrings [ "unzstd -q $src -o $out/bin/claude" ] [ "cp $src $out/bin/claude" ]
            (
              if prev.stdenv.hostPlatform.isDarwin then
                builtins.replaceStrings
                  [ "--set-default CLAUDE_CODE_CERT_STORE system" ]
                  [ "--set-default CLAUDE_CODE_CERT_STORE bundled,system" ]
                  old.installPhase
              else
                old.installPhase
            );
      });
}
