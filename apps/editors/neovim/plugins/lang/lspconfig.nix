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
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    nvim-lspconfig = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      event = [
        "DeferredUIEnter"
        "BufReadPre"
      ];
      optsExtend = [ [ "keymaps" ] ];
      options = [
        {
          config = { };
          keymaps = [ ];
        }
      ];
      after = {
        path = ./lspconfig.lua;
      };
    };

    fidget-nvim = {
      plugin = pkgs.vimPlugins.fidget-nvim;
      module = "fidget";
      dependencyOf = "nvim-lspconfig";
      options = { };
    };
  };
}
