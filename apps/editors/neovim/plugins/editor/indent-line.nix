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
  home-manager.users.${username}.programs.neovim.lzePlugins.indent-blankline-nvim = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.indent-blankline-nvim;
    module = "ibl";
    event = [
      "BufReadPost"
      "BufNewFile"
    ];
    options = { };
  };
}
