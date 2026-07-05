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
  home-manager.users.${username}.programs.neovim.lzePlugins.neogen = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.neogen;
    command = "Neogen";
    keys = [
      {
        "" = [
          "<leader>cd"
          (luaUtils.mkLuaExpression "function() require('neogen').generate() end")
        ];
        desc = "Generate code documentation";
      }
    ];
    options.snippet_engine = "nvim";
  };
}
