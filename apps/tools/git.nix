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
    home.packages = with pkgs; [
      git-crypt
    ];

    programs = {
      git = {
        enable = true;
        settings = {
          init.defaultBranch = "main";
          merge.tool = "nvimdiff";
          merge.conflictstyle = "zdiff3";
          user = {
            email = "49083526+Landaman@users.noreply.github.com";
            name = "Ian Wright";
          };
        };
      };

      lazygit.enable = true;

      neovim = {
        extraConfigFiles = [
          {
            path = ./gitsigns.lua;
          }
        ];

        lzePlugins = {
          gitsigns-nvim = {
            enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
            plugin = pkgs.vimPlugins.gitsigns-nvim;
            command = "Gitsigns";
            event = [
              "BufReadPost"
              "BufNewFile"
              "BufWritePre"
            ];
            options = {
              path = ./gitsigns.lua;
              call = "opts";
            };
            module = "gitsigns";
          };
          nvim-treesitter.options = [
            {
              ensure_installed = [
                "gitcommit"
                "gitignore"
              ];
            }
          ];
        };
      };
    };
  };
}
