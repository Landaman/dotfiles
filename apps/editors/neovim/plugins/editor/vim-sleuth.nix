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
  home-manager.users.${username}.programs.neovim.lzePlugins.vim-sleuth = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.vim-sleuth;
    event = [
      "BufReadPost"
      "BufNewFile"
    ];
    after = luaUtils.mkLuaExpression "function() end";
  };
}
