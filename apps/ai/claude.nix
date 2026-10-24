{
  pkgs,
  config,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = [ pkgs.claude-code ];

  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "claude" ];
}
