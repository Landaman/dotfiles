{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  webFormat.languages = [
    "markdown"
    {
      nvim = "markdown.mdx";
      vscode = "mdx";
    }
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "markdownlint" ];
      extraPackages = with pkgs; [
        markdownlint-cli
      ];

      lzePlugins = {
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

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.davidanson.vscode-markdownlint ];
        };
  };
}
