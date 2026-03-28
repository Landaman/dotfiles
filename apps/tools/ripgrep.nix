{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.ripgrep = {
    enable = true;
    arguments = builtins.map (globPattern: "--glob=!${globPattern}") config.files.neverShowGlobs;
  };
}
