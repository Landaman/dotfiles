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
  home-manager.users.${username} = {
    programs.neovim.mason.packages = [ "terraform-ls" ];
    home.packages = with pkgs; [
      terraform
    ];

    programs.neovim.extraPackages = with pkgs; [
      terraform-ls
    ];

    programs.neovim.lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "terraform"
          ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config.terraformls = { };
        }
      ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.hashicorp.terraform ];
          userSettings."terraform.languageServer.path" = "${pkgs.terraform-ls}/bin/terraform-ls";
        };
  };
}
