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
      pgformatter
      postgres-language-server
      sql-formatter
    ];

    lzePlugins = {
      nvim-lspconfig.options = [
        {
          config = {
            postgres_lsp = { };
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
            sql_formatter.append_args = [ "--language=postgresql" ];
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
}
