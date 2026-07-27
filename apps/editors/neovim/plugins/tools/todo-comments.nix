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
    todo-comments-nvim = {
      enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
      plugin = pkgs.vimPlugins.todo-comments-nvim;
      module = "todo-comments";
      command = [
        "TodoTrouble"
      ]
      ++ lib.optionals (config.home-manager.users.${username}.programs.neovim.lzePlugins ? fzf-lua) [
        "TodoFzfLua"
      ];
      event = [
        "BufReadPost"
        "BufNewFile"
      ];
      options.signs = false;
      keys = {
        "" = [
          {
            "" = [
              "<leader>wo"
              "<cmd>Trouble todo<cr>"
            ];
            desc = "Todo list";
          }
          {
            "" = [
              "<leader>do"
              "<cmd>Trouble todo filter.buf=0<cr>"
            ];
            desc = "Document todo list";
          }
          {
            "" = [
              "<leader>so"
              "<cmd>TodoFzfLua<cr>"
            ];
            desc = "Search todo";
          }
        ];
      };
    };

    plenary-nvim.dependencyOf = [ "todo-comments.nvim" ];
  };
}
