{
  config,
  lib,
  pkgs,
  ...
}:

let
  luaUtils = import ../../../../../lib/lua.nix { inherit lib; };
  username = config.user.username;
  oil = call: {
    path = ./oil.lua;
    inherit call;
  };
in
{
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    oil-nvim = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.oil-nvim;
      module = "oil";
      command = "Oil";
      beforeAll = oil "beforeAll";
      keys = {
        "" = [
          {
            "" = [
              "\\"
              (oil "open")
            ];
            desc = "Open oil in current files directory";
          }
        ];
      };
      options = oil "opts";
      after = oil "after";
    };

    nvim-web-devicons.dependencyOf = [ "oil.nvim" ];
  };
}
