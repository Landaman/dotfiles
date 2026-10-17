{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.neovim = {
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

    home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
      pkgs.docker
    ];
    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = with pkgs.vscode-extensions; [
            docker.docker
            ms-azuretools.vscode-containers
          ];

          userSettings."vsicons.associations.files" = [
            {
              icon = "docker";
              filenamesGlob = [ "docker-compose.migrate" ];
              extensionsGlob = [
                "yaml"
                "yml"
              ];
              filename = true;
              format = "svg";
            }
          ];
        };
  };

  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "docker-desktop" ];
}
