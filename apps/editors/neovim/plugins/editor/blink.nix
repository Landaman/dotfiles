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
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    blink-cmp = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.blink-cmp;
      module = "blink.cmp";
      event = "InsertEnter";
      options = {
        keymap.preset = "default";
        completion = {
          documentation.auto_show = true;
          menu.draw.treesitter = [ "lsp" ];
        };
        cmdline.enabled = false;
        sources.default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
      };
    };

    friendly-snippets = {
      plugin = pkgs.vimPlugins.friendly-snippets;
      dependencyOf = "blink.cmp";
    };
  };
}
