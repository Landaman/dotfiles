{
  config,
  lib,
  ...
}:
let
  username = config.user.username;
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  nixToLua = import ./neovim/nix-to-lua.nix { inherit lib; };
in
{
  options.webFormat.formatters = lib.mkOption {
    type = lib.types.nonEmptyListOf (
      lib.types.submodule {
        options = {
          conformName = lib.mkOption {
            type = lib.types.str;
            description = "Conform formatter name";
          };
          configFiles = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = "Project configuration filenames that select this formatter";
          };
          vscodeExtension = lib.mkOption {
            type = lib.types.str;
            description = "VSCode extension identifier used as the default formatter";
          };
        };
      }
    );
    description = ''
      Web formatters in selection order. The first matching formatter by config file wins.
      The first entry is also the fallback and the VSCode user default.
    '';
  };

  config.home-manager.users.${username} = {
    options.programs.vscode.webFormattedLanguages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "VSCode language identifiers that use the default web formatter";
    };

    config = {
      programs.neovim.lzePlugins.conform-nvim.options = [
        {
          # Select the first configured web formatter for a buffer, falling back to the first entry
          formatters.web = luaUtils.mkLuaExpression ''
            function(bufnr)
              local formatters = ${nixToLua.toLuaValue config.webFormat.formatters}
              local path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))

              for _, formatter in ipairs(formatters) do
                if #vim.fs.find(formatter.configFiles, { path = path, upward = true, type = "file" }) > 0 then
                  return { inherit = formatter.conformName }
                end
              end

              return { inherit = formatters[1].conformName }
            end
          '';
        }
      ];

      # VSCode uses the first, better extensions + options.json configure the rest
      programs.vscode.profiles.default =
        lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
          {
            userSettings =
              lib.genAttrs
                (map (
                  language: "[${language}]"
                ) config.home-manager.users.${username}.programs.vscode.webFormattedLanguages)
                (_: {
                  "editor.defaultFormatter" = (builtins.head config.webFormat.formatters).vscodeExtension;
                });
          };
    };
  };
}
