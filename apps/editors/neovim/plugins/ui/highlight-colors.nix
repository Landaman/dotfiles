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
  home-manager.users.${username}.programs.neovim.lzePlugins.nvim-highlight-colors = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.nvim-highlight-colors;
    event = [
      "BufReadPost"
      "BufNewFile"
    ];
    options.render = "virtual";
  };
}
