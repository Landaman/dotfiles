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
  home-manager.users.${username}.programs.fd = {
    enable = true;
    extraOptions = builtins.map (globPattern: "--exclude=${globPattern}") config.files.neverShowGlobs;
  };
}
