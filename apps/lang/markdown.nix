{
  config,
  pkgs,
  ...
}:
let
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

      nvim-lint.options = [
        {
          linters_by_ft.markdown = [ "markdownlint" ];
        }
      ];
    };
  };
}
