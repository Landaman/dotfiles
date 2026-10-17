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
  home-manager.users.${username} = {
    programs.neovim = {
      extraPackages = with pkgs; [
        prettierd
        oxfmt
      ];
      lzePlugins.conform-nvim.options = [
        {
          path = ./web-format.lua;
          call = "opts";
        }
      ];
    };
  };
}
