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
    # IBL has an after thing, which we need to separately packadd because otherwise it never gets added
    load = luaUtils.mkLuaExpression ''
      function(name)
        vim.cmd.packadd(name)
        vim.cmd.packadd(name .. "/after")
      end
    '';
    options = { };
  };
}
