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
      keys = [
        {
          lhs = "<F5>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').continue() end";
          desc = "Debug start/continue";
        }
        {
          lhs = "<F6>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').run_last() end";
          desc = "Debug restart";
        }
        {
          lhs = "<F7>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').terminate() end";
          desc = "Debug terminate";
        }
        {
          lhs = "<F1>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').step_into() end";
          desc = "Step into";
        }
        {
          lhs = "<F2>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').step_over() end";
          desc = "Step over";
        }
        {
          lhs = "<F3>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').step_out() end";
          desc = "Step out";
        }
        {
          lhs = "<F4>";
          rhs = luaUtils.mkLuaExpression "function() require('dap').step_back() end";
          desc = "Step back";
        }
        {
          lhs = "<leader>b";
          rhs = luaUtils.mkLuaExpression "function() require('dap').toggle_breakpoint() end";
          desc = "Toggle breakpoint";
        }
        {
          lhs = "<leader>B";
          rhs = luaUtils.mkLuaExpression "function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end";
          desc = "Set breakpoint";
        }
        {
          lhs = "<F10>";
          rhs = luaUtils.mkLuaExpression "function() require('dapui').toggle() end";
          desc = "See last debug session result";
        }
        {
          lhs = "<F9>";
          rhs = luaUtils.mkLuaExpression "function() require('dapui').toggle({ layout = 0, reset = true }) end";
          desc = "Reset debug UI layout";
        }
      ];
      after = {
        path = ./dap.lua;
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
      dependencyOf = "nvim-dap";
    };
  };
}
