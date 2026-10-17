{
  lib,
  config,
  pkgs,
  ...
}:
let
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  username = config.user.username;
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
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
        # Rustacean relies on ftplugin files, but packadd only updates runtimepath.
        # The FileType event already fired before lze loads the plugin, so source them here.
        load = luaUtils.mkLuaExpression ''
          function(name)
            vim.cmd.packadd(name)
            for _, ext in ipairs({ "vim", "lua" }) do
              for _, path in ipairs(vim.api.nvim_get_runtime_file("ftplugin/rust." .. ext, true)) do
                if path:match("/pack/[^/]+/opt/" .. vim.pesc(name) .. "/ftplugin/rust%." .. ext .. "$") then
                  vim.cmd.source(vim.fn.fnameescape(path))
                end
              end
            end
          end
        '';
        options = [
          {
            codelldb_path = "${codelldb}/bin/codelldb";
            liblldb_path = "${codelldb}/share/lldb/lib/liblldb.dylib";
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

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.rust-lang.rust-analyzer ];
          userSettings = {
            "rust-analyzer.server.path" = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
        };
  };

  environment.systemPackages = with pkgs; [
    cargo
    rustc
  ];
}
