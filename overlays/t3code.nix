final: prev:
let
  version = "0.0.45";

  unwrapped = prev.t3code.unwrapped.overrideAttrs (
    finalAttrs: _: {
      inherit version;

      src = final.fetchFromGitHub {
        owner = "pingdotgg";
        repo = "t3code";
        tag = "v${version}";
        hash = "sha256-8drTHjFqa2vJ96jhpRZXmNbtbXtKk1q40jOEp9dohNc=";
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
        hash = "sha256-2dGEHOQrnidTei54NlZTJh5u5/i810hb2LddK4XfUNQ=";
      };
    }
  );

  resourceMonitor = prev.t3code.resourceMonitor.override {
    t3code-unwrapped = unwrapped;
  };
in
{
  t3code = prev.t3code.override {
    t3code-unwrapped = unwrapped;
    t3code-resource-monitor = resourceMonitor;
  };
}
