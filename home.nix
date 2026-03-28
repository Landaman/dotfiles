{
  pkgs,
  config,
  lib,
  ...
}:
{
  targets.darwin = {
    copyApps = {
      enable = true;
    };
    linkApps = {
      enable = false;
    };
  };

  # Tell Home Manager who it is managing in this config
  home.username = "ianwright";
  home.homeDirectory = "/Users/ianwright";

  # Used for backwards compatibility, please read the changelog before changing.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
