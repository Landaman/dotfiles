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
  home-manager.users.${username}.home = {
    activation.herdrClaudeIntegration = lib.mkIf herdrInstalled (
      # Setup herdr, which needs .claude to exist (it won't if you're installing)
      homeManager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.claude"
        ${pkgs.herdr}/bin/herdr integration install claude
      ''
    );

    packages = [ pkgs.claude-code ];
  };

  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "claude" ];
}
