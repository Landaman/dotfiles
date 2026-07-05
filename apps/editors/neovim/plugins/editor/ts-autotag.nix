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
  home-manager.users.${username}.programs.neovim.lzePlugins.nvim-ts-autotag = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.nvim-ts-autotag;
    event = [
      "BufReadPost"
      "BufNewFile"
    ];
    options = { };
    onPlugin = "nvim-treesitter";
  };
}
