{
  config,
  lib,
  pkgs,
  ...
}:

let
  luaUtils = import ../../../../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.neovim = {
    extraConfigFiles = [
      {
        path = ./gitsigns.lua;
      }
    ];

    lzePlugins.gitsigns-nvim = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.gitsigns-nvim;
      command = "Gitsigns";
      event = [
        "BufReadPost"
        "BufNewFile"
        "BufWritePre"
      ];
      options = {
        path = ./gitsigns.lua;
        call = "opts";
      };
      module = "gitsigns";
    };
  };
}
