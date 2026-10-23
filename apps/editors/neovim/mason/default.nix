{ config, ... }:
{
  home-manager.users.${config.user.username}.imports = [
    ./mason.nix
  ];
}
