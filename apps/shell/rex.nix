{
  config,
  flake,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [ flake.inputs.rex.homeManagerModules.default ];

  home-manager.users.${config.user.username} = {
    programs.rex = {
      enable = true;
      package = pkgs.rex;
      sshGuard = false; # SSH is not currently managed in this flake
    };
  };
}
