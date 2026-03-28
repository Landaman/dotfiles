{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    bitwarden-cli
  ];

  homebrew.masApps = {
    bitwarden = 1352778147;
  };
}
