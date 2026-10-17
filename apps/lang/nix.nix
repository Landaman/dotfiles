{
  config,
  lib,
  pkgs,
  nixpkgs,
  flake,
  ...
}:
let
  username = config.user.username;
  nixdSettings = {
    formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
    options = {
      nix-darwin.expr = "(builtins.getFlake (builtins.toString <flakepath>)).editorDarwinConfiguration.options";
      home-manager.expr = "(builtins.getFlake (builtins.toString <flakepath>)).editorHomeManagerConfiguration.options";
    };
  };
in
{
  # This allows nixd to find the Flake easier
  nix.nixPath = [
    "nixpkgs=${nixpkgs}" # Nixd looks for this even if not explicitly requested
    "flakepath=${flake.outPath}"
  ];

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      nixd
      nixfmt
    ];

    programs.neovim = {
      extraPackages = with pkgs; [
        nixd
        nixfmt
      ];

      lzePlugins = {
        nvim-treesitter.options = [
          {
            ensure_installed = [
              "nix"
            ];
          }
        ];

        nvim-lspconfig.options = [
          {
            config.nixd.settings.nixd = nixdSettings;
          }
        ];
      };
    };

    programs.vscode.profiles.default =
      lib.mkIf config.home-manager.users.${username}.programs.vscode.enable
        {
          extensions = [ pkgs.vscode-extensions.jnoortheen.nix-ide ];
          userSettings = {
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
            "nix.serverSettings".nixd = nixdSettings;
            "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          };
        };
  };
}
