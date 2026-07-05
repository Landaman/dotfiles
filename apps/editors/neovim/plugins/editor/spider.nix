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
  home-manager.users.${username}.programs.neovim.lzePlugins.nvim-spider = {
    plugin = pkgs.vimPlugins.nvim-spider;
    module = "spider";
    options.skipInsignificantPunctuation = false;
    keys = [
      {
        "" = [
          "w"
          (luaUtils.mkLuaExpression "function() require('spider').motion('w') end")
        ];
        mode = [
          "n"
          "o"
          "x"
        ];
      }
      {
        "" = [
          "e"
          (luaUtils.mkLuaExpression "function() require('spider').motion('e') end")
        ];
        mode = [
          "n"
          "o"
          "x"
        ];
      }
      {
        "" = [
          "b"
          (luaUtils.mkLuaExpression "function() require('spider').motion('b') end")
        ];
        mode = [
          "n"
          "o"
          "x"
        ];
      }
    ];
  };
}
