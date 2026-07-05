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
  home-manager.users.${username}.programs.neovim.lzePlugins.copilot-lua = {
    enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
    plugin = pkgs.vimPlugins.copilot-lua;
    command = "Copilot";
    module = "copilot";
    event = "BufReadPost";
    options = {
      suggestion = {
        auto_trigger = true;
        keymap = {
          accept = "<Tab>";
          accept_word = "<M-Right>";
          accept_line = "<M-C-Right>";
          next = "<M-]>";
          prev = "<M-[>";
          dismiss = "<C-]>";
        };
      };
      panel.enabled = false;
    };
  };
}
