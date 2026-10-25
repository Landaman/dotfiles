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
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.biomejs.biome ];
        };
  };
}
