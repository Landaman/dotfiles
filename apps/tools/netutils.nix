{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    wget
  ];

  home-manager.users.${config.user.username}.home.packages = with pkgs; [
    inetutils
  ];
}
