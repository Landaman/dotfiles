{
  config,
  pkgs,
  ...
}:
{
  home-manager.users.${config.user.username}.home.packages = [
    pkgs.mongodb-compass
  ];
}
