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
    nvim-dap = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.nvim-dap;
      options = [
        { handlers = { }; }
      ];
      keys = {
        path = ./dap.lua;
        call = "keys";
      };
      after = {
        path = ./dap.lua;
        call = "after";
      };
    };

    nvim-dap-ui = {
      plugin = pkgs.vimPlugins.nvim-dap-ui;
      dependencyOf = "nvim-dap";
      options = [ { } ];
      after = {
        path = ./dapui.lua;
      };
    };

    nvim-dap-virtual-text = {
      plugin = pkgs.vimPlugins.nvim-dap-virtual-text;
      dependencyOf = "nvim-dap";
      options = [
        {
          clear_on_continue = false;
          enabled_commands = true;
        }
      ];
    };

    nvim-nio = {
      plugin = pkgs.vimPlugins.nvim-nio;
      dependencyOf = "nvim-dap-ui";
    };

    plenary-nvim = {
      plugin = pkgs.vimPlugins.plenary-nvim;
      dependencyOf = [ "nvim-dap" ];
    };
  };
}
