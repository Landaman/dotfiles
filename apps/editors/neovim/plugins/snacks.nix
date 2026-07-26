{
  config,
  lib,
  pkgs,
  ...
}:

let
  luaUtils = import ../../../../lib/lua.nix { inherit lib; };
  username = config.user.username;
  snacks = call: {
    path = ./snacks.lua;
    inherit call;
  };
in
{
  home-manager.users.${username}.programs.neovim.lzePlugins = {
    snacks-nvim = {
      plugin = pkgs.vimPlugins.snacks-nvim;
      module = "snacks";
      lazy = false;
      priority = 1000;
      beforeAll = snacks "beforeAll";
      keys = {
        "" = [
          {
            "" = [
              "]]"
              (snacks "nextReference")
            ];
            desc = "Next reference";
            mode = [
              "n"
              "t"
            ];
          }
          {
            "" = [
              "[["
              (snacks "previousReference")
            ];
            desc = "Previous reference";
            mode = [
              "n"
              "t"
            ];
          }
        ];
      };
      options = {
        bigfile.enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        dashboard = {
          enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
          sections = [
            { section = "header"; }
            {
              section = "keys";
              gap = 1;
              padding = 1;
            }
          ];
          preset = {
            header = luaUtils.mkLuaExpression ''
              "Neovim v" .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
            '';
            footer = luaUtils.mkLuaExpression ''vim.fn.strftime("%Y-%m-%d %H:%M:%S")'';
            keys = [
              {
                icon = " ";
                key = "f";
                desc = "Find File";
                action = "<leader>sf";
              }
              {
                icon = " ";
                key = "F";
                desc = "Find Directory";
                action = "<leader>sF";
              }
              {
                icon = " ";
                key = "n";
                desc = "New File";
                action = ":ene | startinsert";
              }
              {
                icon = " ";
                key = "g";
                desc = "Find Text";
                action = "<leader>sg";
              }
              {
                icon = " ";
                key = "c";
                desc = "Config";
                action = luaUtils.mkLuaExpression ''
                  function()
                    vim.cmd("cd " .. vim.fn.stdpath("config"))
                    Snacks.dashboard.pick("files", { cwd = vim.fn.stdpath("config") })
                  end
                '';
              }
              {
                icon = " ";
                key = "q";
                desc = "Quit";
                action = ":qa";
              }
            ];
          };
        };
        quickfile.enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        statuscolumn.enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        words.enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        scratch.enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        scope = {
          enabled = true;
          keys = {
            textobject = {
              ii.desc = "Inner scope";
              ai.desc = "Full scope";
            };
            jump = {
              "[i".desc = "Top edge of scope";
              "]i".desc = "Bottom edge of scope";
            };
          };
        };
      };
      after = snacks "after";
    };

    nvim-lspconfig.options = [
      {
        keymaps = [
          {
            "" = [
              "]]"
              (snacks "nextReference")
            ];
            desc = "Next reference";
            mode = [
              "n"
              "t"
            ];
            has = "documentHighlight";
          }
          {
            "" = [
              "[["
              (snacks "previousReference")
            ];
            desc = "Previous reference";
            mode = [
              "n"
              "t"
            ];
            has = "documentHighlight";
          }
        ];
      }
    ];
  };
}
