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
  home-manager.users.${username}.programs.neovim.lzePlugins.nvim-lint = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.nvim-lint;
    event = [
      "BufReadPre"
      "BufNewFile"
    ];
    options = [
      {
        linters_by_ft = { };
      }
    ];
    after = {
      path = ./lint.lua;
    };
  };
}
