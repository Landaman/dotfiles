{
  config,
  lib,
  pkgs,
  ...
}:
let
  luaUtils = import ../../../lib/lua.nix { inherit lib; };
  username = config.user.username;
in
{
  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [ "eslint-lsp" ];
      extraPackages = [ pkgs.vscode-langservers-extracted ];

      lzePlugins.nvim-lspconfig.options = [
        {
          config.eslint = {
            settings.nodePath = luaUtils.mkLuaExpression ''
              (function()
                local yarn_directory = vim.fs.find(".yarn/sdks", { upward = true, type = "directory" })[1]
                return yarn_directory and vim.fn.isdirectory(yarn_directory) == 1 and yarn_directory or nil
              end)()
            '';
          };
        }
      ];
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.dbaeumer.vscode-eslint ];
          userSettings."eslint.workingDirectories" = [ { mode = "auto"; } ];
        };
  };
}
