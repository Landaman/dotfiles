final: prev:
let
  version = "0.0.38";

  unwrapped = prev.t3code.unwrapped.overrideAttrs (finalAttrs: _: {
    inherit version;

    src = final.fetchFromGitHub {
      owner = "pingdotgg";
      repo = "t3code";
      tag = "v${version}";
      hash = "sha256-lbAOIlNwVxrjXA5jJGzmOm7Fe2ZcsnFuDzaSEt6R7G4=";
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
      hash = "sha256-t/hmpXdYPnBFx18A6NrSL4zSvVnUDIjIPtLjGOzoaDk=";
    };
  });

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
