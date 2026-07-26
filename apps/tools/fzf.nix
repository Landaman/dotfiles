{
  config,
  lib,
  pkgs,
  ...
}:
let
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.fzf = rec {
      enable = true;
      defaultCommand = ''
        fd --type f --follow --strip-cwd-prefix --color=never --hidden ${
          lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") config.files.neverShowGlobs
        }
      '';
      fileWidgetCommand = "${defaultCommand}";
      changeDirWidgetCommand = ''
        fd --type d --follow --color=never --hidden ${
          lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") config.files.neverShowGlobs
        }
      '';
      defaultOptions = [
        "--multi"
      ]
      ++ lib.optionals config.home-manager.users.${username}.programs.tmux.enable [ "--tmux" ];
      tmux = lib.mkIf config.home-manager.users.${username}.programs.tmux.enable {
        enableShellIntegration = true;
        shellIntegrationOptions = [ "-p" ];
      };
    };

    programs.neovim.lzePlugins.fzf-lua = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.fzf-lua;
      command = "FzfLua";
      beforeAll = {
        path = ./fzf.lua;
        call = "beforeAll";
      };
      keys = {
        "" = [
          {
            "" = [
              "<leader>sf"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').files() end")
            ];
            desc = "Search files";
          }
          {
            "" = [
              "<leader>sF"
              {
                path = ./fzf.lua;
                call = "directories";
              }
            ];
            desc = "Search directories";
          }
          {
            "" = [
              "<leader>sp"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').builtin() end")
            ];
            desc = "Search pickers";
          }
          {
            "" = [
              "<leader>sw"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').grep_cword() end")
            ];
            desc = "Search cursor word";
          }
          {
            "" = [
              "<leader>sg"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').live_grep() end")
            ];
            desc = "Search live grep";
          }
          {
            "" = [
              "<leader>sd"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').diagnostics_workspace() end")
            ];
            desc = "Search diagnostics";
          }
          {
            "" = [
              "<leader>sr"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').resume() end")
            ];
            desc = "Search resume";
          }
          {
            "" = [
              "<leader>s."
              (luaUtils.mkLuaExpression "function() require('fzf-lua').oldfiles() end")
            ];
            desc = "Search recent files";
          }
          {
            "" = [
              "<leader><leader>"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').buffers() end")
            ];
            desc = "Find existing buffers";
          }
          {
            "" = [
              "<leader>s/"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lgrep_curbuf() end")
            ];
            desc = "Fuzzily search in current buffer";
          }
          {
            "" = [
              "grr"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_references() end")
            ];
            desc = "Search references";
          }
          {
            "" = [
              "gri"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_implementations() end")
            ];
            desc = "Search implementations";
          }
          {
            "" = [
              "gry"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_typedefs() end")
            ];
            desc = "Search type definitions";
          }
          {
            "" = [
              "gra"
              {
                path = ./fzf.lua;
                call = "codeActions";
              }
            ];
            desc = "Code actions";
          }
          {
            "" = [
              "gO"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_document_symbols() end")
            ];
            desc = "Search document symbols";
          }
          {
            "" = [
              "gP"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_workspace_symbols() end")
            ];
            desc = "Search workspace symbols";
          }
          {
            "" = [
              "gd"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_definitions() end")
            ];
            desc = "Search definitions";
          }
          {
            "" = [
              "gD"
              (luaUtils.mkLuaExpression "function() require('fzf-lua').lsp_declarations() end")
            ];
            desc = "Search declarations";
          }
        ];
      };
      options = {
        "" = [ ] ++ lib.optionals config.home-manager.users.${username}.programs.tmux.enable [ "fzf-tmux" ];
        previewers.codeaction_native.pager =
          lib.mkIf config.home-manager.users.${username}.programs.delta.enable
            (
              luaUtils.mkLuaExpression ''vim.fn.executable 'delta' and [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]] or nil''
            );
      };
    };

    programs.neovim.lzePlugins.nvim-web-devicons.dependencyOf = [ "fzf-lua" ];
  };
}
