{ rex }:
final: _prev:
let
  package = rex.packages.${final.stdenv.hostPlatform.system}.default;
in
{
  rex = final.symlinkJoin {
    inherit (package) name;
    paths = [ package ];
    nativeBuildInputs = [ final.installShellFiles ];
    postBuild = ''
      installShellCompletion --cmd rex \
        --bash <(${package}/bin/rex completion bash) \
        --fish <(${package}/bin/rex completion fish) \
        --zsh <(${package}/bin/rex completion zsh)
    '';
    inherit (package) meta;
  };
}
