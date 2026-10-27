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
        # Setup herdr, which needs .codex to exist (it won't if you're installing)
        homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p "$HOME/.codex"
          ${pkgs.herdr}/bin/herdr integration install codex
        ''
      );

      packages = (
        with pkgs;
        [
          chatgpt
        ]
      );
    };

    programs.codex = {
      enable = true;
      package = pkgs.codex;

      # Codex LOVES to change its settings
      mutableSettings = true;

      settings.tui.statusline = [
        "model-with-reasoning"
        "current-dir"
        "git-branch"
        "branch-changes"
        "approval-mode"
        "five-hour-limit"
        "weekly-limit"
        "used-tokens"
        "fast-mode"
        "estimated-thread-cost"
      ];
    };
  };
}
