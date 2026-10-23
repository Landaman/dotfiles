{
  config,
  lib,
  pkgs,
  ...
}:
let
  luaUtils = import ../../lib/lua.nix { inherit lib; };
  username = config.user.username;
  dotrush = pkgs.callPackage ../../packages/dotrush.nix { };
  clrdbg = pkgs.callPackage ../../packages/clrdbg.nix { };
in
{
  environment.systemPackages = [ pkgs.dotnetCorePackages.sdk_10_0 ];

  home-manager.users.${username} = {
    programs.neovim = {
      mason.packages = [
        "dotrush"
        "clrdbg"
      ];
      mason.registryPackages = {
        dotrush = {
          description = "DotRush C# language server";
          homepage = "https://github.com/JaneySprings/DotRush";
          licenses = [ "MIT" ];
          languages = [ "C#" ];
          categories = [ "LSP" ];
          source = {
            id = "pkg:generic/JaneySprings/DotRush@latest";
            download.files."dotrush.zip" =
              "https://github.com/JaneySprings/DotRush/releases/latest/download/DotRush.Bundle.LanguageServer.zip";
          };
          bin.dotrush = "dotnet:DotRush.dll";
        };
        clrdbg = {
          description = ".NET debug adapter used by DotRush";
          homepage = "https://github.com/JaneySprings/clrdbg";
          licenses = [ "MIT" ];
          languages = [ "C#" ];
          categories = [ "DAP" ];
          source = {
            id = "pkg:generic/JaneySprings/clrdbg@latest";
            download =
              map
                (target: {
                  inherit (target) target;
                  files."libexec/clrdbg.zip" =
                    "https://github.com/JaneySprings/clrdbg/releases/latest/download/clrdbg_${target.runtime}.zip";
                })
                [
                  {
                    target = "darwin_arm64";
                    runtime = "osx-arm64";
                  }
                  {
                    target = "darwin_x64";
                    runtime = "osx-x64";
                  }
                  {
                    target = "linux_arm64_gnu";
                    runtime = "linux-arm64";
                  }
                  {
                    target = "linux_x64_gnu";
                    runtime = "linux-x64";
                  }
                ];
          };
          bin.clrdbg = "exec:libexec/clrdbg";
        };
      };
      extraPackages = [
        dotrush
        clrdbg
      ];

      lzePlugins = {
        nvim-treesitter.options = [ { ensure_installed = [ "c_sharp" ]; } ];

        nvim-lspconfig.options = [
          {
            config.dotrush = {
              cmd = [ "dotrush" ];
              filetypes = [ "cs" ];
              root_dir = luaUtils.mkLuaExpression ''
                function(bufnr, on_dir)
                  local root = vim.fs.root(bufnr, function(name)
                    return name:match("%.sln$") or name:match("%.slnx$") or name:match("%.csproj$") or name == ".git"
                  end)
                  if root then
                    on_dir(root)
                  end
                end
              '';
              workspace_required = true;
              settings.dotrush.roslyn = luaUtils.mkLuaExpression "vim.empty_dict()";
            };
          }
        ];

        nvim-dap.optsExtend = [ [ "adapters" ] ];
        nvim-dap.options = [
          {
            adapters = [ { path = ./csharp.lua; } ];
          }
        ];
      };
    };
    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [
            (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
              mktplcRef = {
                publisher = "nromanov";
                name = "dotrush";
                version = "26.10.277";
              };
              vsix = pkgs.fetchurl {
                url = "https://github.com/JaneySprings/DotRush/releases/download/2026.10/DotRush.v26.10.277.vsix";
                hash = "sha256-ajlgbKKfKo8A8HzD4pkgD1cpteum0E0awV5YSp79guo=";
              };
              # Otherwise DotRush downloads its debugger into the immutable extension directory
              postInstall = ''
                ln -s ${clrdbg}/lib/clrdbg "$out/$installPrefix/extension/bin/Debugger"
              '';
            })
          ];
          userSettings."dotrush.roslyn.dotnetSdkDirectory" =
            "${pkgs.dotnetCorePackages.sdk_10_0}/share/dotnet/sdk/${pkgs.dotnetCorePackages.sdk_10_0.version}";
        };
  };
}
