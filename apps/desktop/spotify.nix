{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  window.floatingApps = [ "com.spotify.client" ];

  home-manager.users.${username}.home.packages = with pkgs; [
    spotify
  ];
}
