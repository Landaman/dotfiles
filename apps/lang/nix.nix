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
    home.packages = with pkgs; [
      nixd
      nixfmt
    ];

    programs.neovim = {
      extraPackages = with pkgs; [
        nixd
        nixfmt
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "nix"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.nixd.settings.nixd = {
              formatting.command = [ "nixfmt" ];
              options = {
                nix-darwin.expr = "(builtins.getFlake (builtins.toString <flakepath>)).editorDarwinConfiguration.options";
                home-manager.expr = "(builtins.getFlake (builtins.toString <flakepath>)).editorHomeManagerConfiguration.options";
              };
            };
          }
        ];
      };
    };
  };
}
