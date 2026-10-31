{
  config,
  pkgs,
  ...
}:
{
  home-manager.users.${config.user.username} = {
    programs.rex = {
      enable = true;
      package = pkgs.rex;
      sshGuard = false; # SSH is not currently managed in this flake
    };
  };
}
