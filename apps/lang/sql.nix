{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
  # Keep Prisma installation and configuration tied to the vtsls integration
  hasVtsls = lib.elem pkgs.vtsls config.home-manager.users.${username}.programs.neovim.extraPackages;
in
{
  home-manager.users.${username} = {
    programs.neovim = {
      extraPackages = with pkgs; [
        pgformatter
        postgres-language-server
        sql-formatter
      ];

      lzePlugins = {
        nvim-lspconfig.options = [
          {
            config = {
              postgres_lsp = { };
            }
            // lib.optionalAttrs hasVtsls {
              prismals = { };
            };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft.sql = {
              "" = [
                "pg_format"
                "sql_formatter"
              ];
              stop_after_first = false;
            };
            formatters = {
              sql_formatter = { };
              pg_format.append_args = [
                "--spaces=2"
                "--keep-newline"
                "--wrap-limit=80"
              ];
            };
          }
        ];

        nvim-treesitter.options = [
          {
            ensure_installed = [
              "prisma"
            ];
          }
        ];
      };
    };

    programs.lazysql.enable = true;

    home.packages = with pkgs; [
      sqlite
    ];

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "mtxr";
                name = "sqltools";
                version = "0.28.6";
                hash = "sha256-SpVFH+Qf9tpnNm4J5z3fOhWzzYP0LknDNm88JHMxkIU=";
              };
            })
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "Supabase";
                name = "postgrestools";
                version = "1.4.0";
                hash = "sha256-cz552tssmaw4ti0VlQJ3UJj8niH/5CYaWowqoQs62TA=";
              };
            })
          ];
        };
  };
}
