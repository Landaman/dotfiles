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
  webFormat.formatters = [
    {
      conformName = "biome";
      conformOptions = {
        lsp_format = "prefer";
        name = "biome";
      };
      configFiles = [
        "biome.json"
        "biome.jsonc"
        ".biome.json"
        ".biome.jsonc"
      ];
      vscodeExtension = "biomejs.biome";
    }
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "biome" ];
      extraPackages = [ pkgs.biome ];
      lzePlugins.nvim-lspconfig.options = [
        {
          config.biome = { };
        }
      ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.biomejs.biome ];
        };
  };
}
