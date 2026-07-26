{ config, pkgs, ... }:

let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim.lzePlugins.mini-nvim = {
    plugin = pkgs.vimPlugins.mini-nvim;
    event = "DeferredUIEnter";
    after = {
      path = ./mini.lua;
    };
  };
}
