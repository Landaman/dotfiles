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
  webFormat.formatters = lib.mkBefore [
    {
      conformName = "prettierd";
      configFiles = [
        ".prettierrc"
        ".prettierrc.json"
        ".prettierrc.yml"
        ".prettierrc.yaml"
        ".prettierrc.json5"
        ".prettierrc.js"
        ".prettierrc.ts"
        ".prettierrc.mjs"
        ".prettierrc.mts"
        ".prettierrc.cjs"
        ".prettierrc.cts"
        ".prettierrc.toml"
        "prettier.config.js"
        "prettier.config.ts"
        "prettier.config.mjs"
        "prettier.config.mts"
        "prettier.config.cjs"
        "prettier.config.cts"
      ];
      vscodeExtension = "esbenp.prettier-vscode";
    }
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "prettierd" ];
      extraPackages = [ pkgs.prettierd ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.esbenp.prettier-vscode ];
        };
  };
}
