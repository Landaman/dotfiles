final: prev:
let
  version = "2.1.330";
in
{
  claude-code =
    (prev.claude-code.override {
      manifest = {
        inherit version;
        platforms = {
          darwin-arm64 = {
            binary = "claude";
            checksum = "sha256-98UJO53WVg0Iryi8J7Ej+1UJHerjGArDnfGZUi2oaBU=";
          };
          linux-arm64 = {
            binary = "claude";
            checksum = "sha256-YBb5DKx4PjZ/saqXx2ii77lKASiltGtw+z2Py72d1EQ=";
          };
          linux-x64 = {
            binary = "claude";
            checksum = "sha256-85DqoIFOahv/dMu0est0y5yJ0wztgJ/gr1rwDHv+jrs=";
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
