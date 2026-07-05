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
  home-manager.users.${username}.programs.neovim.lzePlugins.ts-comments-nvim = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    module = "ts-comments";
    plugin = pkgs.vimPlugins.ts-comments-nvim;
    event = "DeferredUIEnter";
    options = { };
  };
}
