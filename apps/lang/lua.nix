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

  home-manager.users.${username}.programs.neovim = {
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
}
