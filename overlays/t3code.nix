final: prev:
let
  version = "0.1.0";

  unwrapped = prev.t3code.unwrapped.overrideAttrs (
    finalAttrs: _: {
      inherit version;

      src = final.fetchFromGitHub {
        owner = "pingdotgg";
        repo = "t3code";
        tag = "v${version}";
        hash = "sha256-P82DqoY1E9wtROwu5Nr7MB/I1PdmZHWXXR4nRa4GWXM=";
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (finalAttrs)
          pname
          version
          src
          pnpmWorkspaces
          ;
        pnpm = final.pnpm_11;
        fetcherVersion = 4;
        hash = "sha256-oX4tOu20tYO3ci7VvSEL8eFgxAYWp5HlQFSfAWJGJmg=";
      };
    }
  );

  resourceMonitor = prev.t3code.resourceMonitor.override {
    t3code-unwrapped = unwrapped;
  };
in
{
  t3code =
    (prev.t3code.override {
      t3code-unwrapped = unwrapped;
      t3code-resource-monitor = resourceMonitor;
    }).overrideAttrs
      (oldAttrs: {
        buildCommand =
          oldAttrs.buildCommand
          # LaunchServices must launch Electron itself to report its real PID
          # Preserve the optional provider PATH and resource monitor wrapper
          + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
            launcher="$out/bin/t3code-desktop"
            if [[ -e "$out/bin/.t3code-desktop-wrapped" ]]; then
              launcher="$out/bin/.t3code-desktop-wrapped"
            fi
            rm "$launcher"
            makeWrapper /usr/bin/open "$launcher" \
              --add-flags "-W -n -a ${final.electron_44}/Applications/Electron.app --args ${unwrapped}/libexec/t3code/apps/desktop"
          '';
      });
}
