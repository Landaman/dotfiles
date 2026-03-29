{
  config,
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "tailscale-app" ];

  home-manager.users.${config.user.username} = {
    programs.zsh.plugins = lib.mkIf pkgs.stdenv.isDarwin [
      {
        name = pkgs.tailscale.pname;
        src = "${pkgs.tailscale}/share/zsh/site-functions";
      }
    ];

    home.packages = lib.mkIf (!pkgs.stdenv.isDarwin) [
      pkgs.tailscale
    ];
  };
}
