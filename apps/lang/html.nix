{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  webFormat.languages = [
    "html"
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "html-lsp" ];
      extraPackages = with pkgs; [
        vscode-langservers-extracted
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "html"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.html = { };
          }
        ];
      };
    };
  };
}
