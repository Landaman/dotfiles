# Provide interactive process and resource monitoring
{ config, ... }:
{
  home-manager.users.${config.user.username}.programs.btop = {
    enable = true;
    settings.vim_keys = true;
  };
}
