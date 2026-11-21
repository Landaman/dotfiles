{
  pkgs,
  config,
  lib,
  homeManager,
  _class,
  ...
}:
let
  username = config.user.username;
  herdrInstalled = lib.elem pkgs.herdr (config.home-manager.users.${username}.home.packages or [ ]);
  rexInstalled = lib.elem pkgs.rex (config.home-manager.users.${username}.home.packages or [ ]);
in
{
  home-manager.users.${username}.home = {
    activation.herdrClaudeIntegration = lib.mkIf herdrInstalled (
      # Setup herdr, which needs .claude to exist (it won't if you're installing)
      homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.claude"
        ${pkgs.herdr}/bin/herdr integration install claude
      ''
    );

    activation.rexClaudeIntegration = lib.mkIf rexInstalled (
      homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.rex}/bin/rex skill setup --agent claude
      ''
    );

    packages = [ pkgs.claude-code ];
  };
}
// lib.optionalAttrs (_class == "darwin") {
  homebrew.casks = [ "claude" ];
  menuBar.hiddenApps = [ "com.anthropic.claudefordesktop" ];
}
