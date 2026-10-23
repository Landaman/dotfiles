{
  config,
  hostname,
  lib,
  pkgs,
  nixpkgs,
  flake,
  ...
}:
let
  username = config.user.username;
  host = builtins.toJSON hostname;

  configurationSet =
    if pkgs.stdenv.hostPlatform.isDarwin then "darwinConfigurations" else "nixosConfigurations";
  optionSet = if pkgs.stdenv.hostPlatform.isDarwin then "nix-darwin" else "nixos";

  systemExpr = "(builtins.getFlake (builtins.toString <flakepath>)).${configurationSet}.${host}";

  nixdSettings = {
    formatting.command = [ "nixfmt" ];
    options = {
      ${optionSet}.expr = "${systemExpr}.options";
      home-manager.expr = "${systemExpr}.options.home-manager.users.type.getSubOptions []";
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
