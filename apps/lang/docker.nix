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
      docker-compose-language-service
      dockerfile-language-server
    ];

    lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "dockerfile"
            "yaml"
          ];
        }
      ];

      nvim-lspconfig.options = [
        {
          config = {
            docker_compose_language_service = { };
            dockerls = { };
          };
        }
      ];
    };
  };
}
