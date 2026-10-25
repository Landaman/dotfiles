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
  files.ignoreGlobs = [
    "node_modules/"
    ".turbo/"
    ".yarn/"
    ".firebase/"
    ".next/"
  ];

  environment.systemPackages = with pkgs; [
    nodejs_22
    corepack_22
    bun
  ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "oxlint"
        "eslint-lsp"
        "js-debug-adapter"
        "vtsls"
      ];
      extraPackages = with pkgs; [
        oxlint
        prisma-language-server
        vscode-langservers-extracted
        vscode-js-debug
        vtsls
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "javascript"
              "jsdoc"
              "prisma"
              "typescript"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config = {
              eslint = {
                settings.nodePath = luaUtils.mkLuaExpression ''
                  (function()
                    local yarn_directory = vim.fs.find(".yarn/sdks", { upward = true, type = "directory" })[1]
                    return yarn_directory and vim.fn.isdirectory(yarn_directory) == 1 and yarn_directory or nil
                  end)()
                '';
              };
              oxlint = { };
              vtsls = {
                settings = {
                  vtsls = {
                    enableMoveToFileCodeAction = true;
                    autoUseWorkspaceTsdk = true;
                    experimental.completion.enableServerSideFuzzyMatch = true;
                  };
                  typescript = {
                    tsdk = luaUtils.mkLuaExpression ''
                      (function()
                        local yarn_directory = vim.fs.find(".yarn/sdks", { upward = true, type = "directory" })[1]
                        local tsdk_folder = yarn_directory and (yarn_directory .. "/typescript/lib") or nil
                        return tsdk_folder and vim.fn.isdirectory(tsdk_folder) == 1 and tsdk_folder or nil
                      end)()
                    '';
                    updateImportsOnFileMove.enabled = "always";
                    inlayHints = {
                      enumMemberValues.enabled = true;
                      functionLikeReturnTypes.enabled = true;
                      parameterNames.enabled = "literals";
                      parameterTypes.enabled = true;
                      propertyDeclarationTypes.enabled = true;
                      variableTypes.enabled = false;
                    };
                  };
                };
              };
            };
          }
        ];

        conform-nvim.options = [
          {
            formatters_by_ft = {
              javascript = [ "web" ];
              javascriptreact = [ "web" ];
              typescript = [ "web" ];
              typescriptreact = [ "web" ];
            };
          }
        ];

        nvim-dap.options = [
          {
            adapters = [
              {
                path = ./javascript.lua;
              }
            ];
          }
          {
            handlers = {
              chrome = luaUtils.mkLuaExpression ''
                function(config)
                  if config.webRoot == nil then
                    config.webRoot = vim.fn.getcwd()
                  end
                  return config
                end
              '';
              pwa-chrome = luaUtils.mkLuaExpression ''
                function(config)
                  if config.webRoot == nil then
                    config.webRoot = vim.fn.getcwd()
                  end
                  return config
                end
              '';
            };
          }
        ];
      };
    };

    programs.vscode.webFormattedLanguages = [
      "javascript"
      "javascriptreact"
      "typescript"
      "typescriptreact"
    ];

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = with pkgs.vscode-extensions; [
            dbaeumer.vscode-eslint
            prisma.prisma
            vitest.explorer
            yoavbls.pretty-ts-errors
          ];

          userSettings = {
            "oxc.path.oxlint" = "${pkgs.oxlint}/bin/oxlint";
            "eslint.workingDirectories" = [ { mode = "auto"; } ];
            "typescript.enablePromptUseWorkspaceTsdk" = true;
            "typescript.updateImportsOnFileMove.enabled" = "always";
            "typescript.inlayHints.enumMemberValues.enabled" = true;
            "typescript.inlayHints.functionLikeReturnTypes.enabled" = true;
            "typescript.inlayHints.parameterNames.enabled" = "literals";
            "typescript.inlayHints.parameterTypes.enabled" = true;
            "typescript.inlayHints.propertyDeclarationTypes.enabled" = true;
          };
        };
  };
}
