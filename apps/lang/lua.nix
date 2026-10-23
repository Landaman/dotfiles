{
  config,
  lib,
  pkgs,
  ...
}:
let
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  environment.systemPackages = with pkgs; [
    lua
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "lua-language-server"
        "stylua"
      ];
      extraPackages = with pkgs; [
        lua-language-server
        stylua
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "lua"
              "luadoc"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.lua_ls.settings.Lua = {
              completion.callSnippet = "Disable";
              hint.enable = true;
            };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft.lua = [ "stylua" ];
          }
        ];

        lazydev-nvim = {
          enabled = luaUtils.mkLuaExpression "not vim.g.vscode";
          plugin = pkgs.vimPlugins.lazydev-nvim;
          module = "lazydev"; # Blink requires based on this
          filetype = [ "lua" ];
          onRequire = "lazydev";
          options = [
            {
              library = [
                {
                  path = "luvit-meta/library";
                  words = [ "vim%.uv" ];
                }
              ];
            }
          ];
        };

        luvit-meta = {
          plugin = pkgs.vimPlugins.luvit-meta;
          dependencyOf = "lazydev.nvim";
        };

        blink-cmp.options = [
          {
            sources = {
              default = [ "lazydev" ];
              providers.lazydev = {
                name = "LazyDev";
                module = "lazydev.integrations.blink";
                score_offset = 100;
              };
            };
          }
        ];
        blink-cmp.dependencyOf = [ "lazydev.nvim" ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [
            pkgs.vscode-extensions.sumneko.lua
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "JohnnyMorganz";
                name = "stylua";
                version = "1.7.2";
                hash = "sha256-l/znKp+myNqS8RYVAyBGn5Up9LfXs0HPUr1ZrV4CrKE=";
              };
            })
          ];

          userSettings = {
            "[lua]"."editor.defaultFormatter" = "JohnnyMorganz.stylua";
            "stylua.styluaPath" = "${pkgs.stylua}/bin/stylua";
            "stylua.disableVersionCheck" = true;
            "Lua.completion.callSnippet" = "Disable";
            "Lua.hint.enable" = true;
          };
        };
  };
}
