{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "json-lsp" ];
      extraPackages = with pkgs; [
        vscode-langservers-extracted
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "json"
              "json5"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.jsonls.settings.json = {
              format.enable = true;
              validate.enable = true;
            };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft = {
              json = [ "web" ];
              jsonc = [ "web" ];
            };
          }
        ];
      };
    };

    programs.vscode.webFormattedLanguages = [
      "json"
      "jsonc"
    ];
  };
}
