{
  pkgs,
  config,
  lib,
  homeManager,
  ...
}:
let
  username = config.user.username;
  herdrInstalled = lib.elem pkgs.herdr (config.home-manager.users.${username}.home.packages or [ ]);
in
{
  home-manager.users.${username} = {
    home = {
      file.".codex/AGENTS.md".source = ./AGENTS.md;

      activation.herdrCodexIntegration = lib.mkIf herdrInstalled (
        homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.herdr}/bin/herdr integration install codex
        ''
      );

      packages = (
        with pkgs;
        [
          chatgpt
          codex
        ]
      );
    };

    programs.codex.package = pkgs.codex;
  };
}
