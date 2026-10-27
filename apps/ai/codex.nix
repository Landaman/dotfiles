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
      activation.herdrCodexIntegration = lib.mkIf herdrInstalled (
        # Setup herdr, which needs .claude to exist (it won't if you're installing)
        homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p "$HOME/.claude"
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
