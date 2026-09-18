final: prev:
let
  version = "0.0.42";

  unwrapped = prev.t3code.unwrapped.overrideAttrs (finalAttrs: _: {
    inherit version;

    src = final.fetchFromGitHub {
      owner = "pingdotgg";
      repo = "t3code";
      tag = "v${version}";
      hash = "sha256-YV86WqqpGQwjeovXB0IoE3f/o4IUC5DDVdBEdT4xzjc=";
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
      hash = "sha256-gEY2em9pNTC1EuVX0V3L/Wu1apZ+BKBXxALEcPQ/pwA=";
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
