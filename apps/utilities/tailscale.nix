{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "tailscale-app" ];

  home-manager.users.${config.user.username} = {
    programs.zsh.plugins = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [
      {
        name = pkgs.tailscale.pname;
        src = "${pkgs.tailscale}/share/zsh/site-functions";
      }
    ];

    home.packages = lib.mkIf (!pkgs.stdenv.hostPlatform.isDarwin) [
      pkgs.tailscale
    ];
  };
}
