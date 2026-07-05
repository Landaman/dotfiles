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
  home-manager.users.${username}.programs.neovim.lzePlugins.which-key-nvim = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.which-key-nvim;
    module = "which-key";
    event = "DeferredUIEnter";
    options = {
      icons.mappings = false;
      spec = [
        {
          "" = "gr";
          group = "LSP Actions";
        }
        {
          "" = "<leader>c";
          group = "Code";
        }
        {
          "" = "<leader>d";
          group = "Document";
        }
        {
          "" = "<leader>s";
          group = "Search";
        }
        {
          "" = "<leader>w";
          group = "Workspace";
        }
        {
          "" = "<leader>h";
          group = "Git hunk";
          mode = [
            "n"
            "v"
          ];
        }
      ];
    };
  };
}
