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
    nvim-treesitter = {
      plugin = pkgs.vimPlugins.nvim-treesitter;
      event = "DeferredUIEnter";
      optsExtend = [ [ "ensure_installed" ] ];
      options = [
        {
          highlight.enable = true;
          ensure_installed = [
            "bash"
            "diff"
            "markdown"
            "markdown_inline"
            "query"
            "regex"
            "vim"
            "vimdoc"
            "csv"
          ];
        }
      ];
      after = {
        path = ./treesitter.lua;
        call = "after";
      };
    };

    nvim-treesitter-context = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.nvim-treesitter-context;
      module = "treesitter-context";
      dependencyOf = "nvim-treesitter";
      options = [
        {
          enable = true;
          max_lines = 5;
          trim_scope = "outer";
          mode = "cursor";
          multiline_threshold = 1;
        }
      ];
    };

    nvim-treesitter-textobjects = {
      plugin = pkgs.vimPlugins.nvim-treesitter-textobjects;
      dependencyOf = "nvim-treesitter";
      options = [
        {
          select.lookahead = true;
          move.set_jumps = true;
        }
      ];
      keys = {
        path = ./treesitter.lua;
        call = "keys";
      };
    };
  };
}
