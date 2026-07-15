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
      rustfmt
      clippy
      rust-analyzer
    ];

    programs.neovim.lzePlugins = {
      nvim-treesitter.options = [
        {
          ensure_installed = [
            "ron"
            "rust"
          ];
        }
      ];

      conform-nvim.options = [
        {
          formatters_by_ft.rust = [ "rustfmt" ];
        }
      ];

      rustaceanvim = {
        plugin = pkgs.vimPlugins.rustaceanvim;
        filetype = [ "rust" ];
        options = [
          {
            server.default_settings.rust-analyzer = {
              cargo = {
                allFeatures = true;
                loadOutDirsFromCheck = true;
                buildScripts.enable = true;
              };
              checkOnSave = true;
              diagnostics.enable = true;
              procMacro.enable = true;
              files = {
                exclude = [
                  ".direnv"
                  ".git"
                  ".jj"
                  ".github"
                  ".gitlab"
                  "bin"
                  "node_modules"
                  "target"
                  "venv"
                  ".venv"
                ];
                watcher = "client";
              };
            };
          }
        ];
        after = {
          path = ./rust.lua;
        };
      };

      crates-nvim = {
        plugin = pkgs.vimPlugins.crates-nvim;
        module = "crates";
        event = [ "BufRead Cargo.toml" ];
        options = [
          {
            completion.crates.enabled = true;
            lsp = {
              enabled = true;
              actions = true;
              completion = true;
              hover = true;
            };
          }
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    cargo
    rustc
  ];
}
