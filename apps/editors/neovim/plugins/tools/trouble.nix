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
  home-manager.users.${username}.programs.neovim.lzePlugins.trouble-nvim = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.trouble-nvim;
    module = "trouble";
    command = "Trouble";
    options = { };
    keys = {
      "" = [
        {
          "" = [
            "<leader>wq"
            "<cmd>Trouble diagnostics toggle<cr>"
          ];
          desc = "Trouble workspace diagnostics";
        }
        {
          "" = [
            "<leader>dd"
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"
          ];
          desc = "Trouble document diagnostics";
        }
      ];
    };
  };
}
