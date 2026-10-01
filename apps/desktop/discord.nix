{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  window.floatingApps = [ "com.hnc.Discord" ];

  home-manager.users.${username}.home.packages = with pkgs; [
    discord
  ];
}
