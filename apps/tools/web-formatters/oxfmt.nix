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
      conformName = "oxfmt";
      configFiles = [
        ".oxfmtrc.json"
        ".oxfmtrc.jsonc"
        "oxfmt.config.ts"
        "oxfmt.config.mts"
      ];
      vscodeExtension = "oxc.oxc-vscode";
    }
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "oxfmt" ];
      extraPackages = [ pkgs.oxfmt ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.oxc.oxc-vscode ];

          # Oxfmt projects select Oxc in workspace settings
          userSettings."oxc.path.oxfmt" = "${pkgs.oxfmt}/bin/oxfmt";
        };
  };
}
