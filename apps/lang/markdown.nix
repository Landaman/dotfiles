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
  home-manager.users.${username}.programs.neovim = {
    extraPackages = with pkgs; [
      markdownlint-cli
      prettierd
    ];

    lzePlugins = {
      conform-nvim.options = [
        {
          formatters_by_ft = {
            markdown = [ "web" ];
            "markdown.mdx" = [ "web" ];
          };
        }
      ];

      nvim-treesitter.options = [
        {
          ensure_installed = [
            "markdown"
            "markdown_inline"
          ];
        }
      ];

      nvim-lint = {
        enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
        plugin = pkgs.vimPlugins.nvim-lint;
        event = [ "BufWritePost" ];
        options = [
          {
            linters_by_ft.markdown = [ "markdownlint" ];
          }
        ];
        after = {
          path = ./markdown.lua;
        };
      };
    };
  };
}
