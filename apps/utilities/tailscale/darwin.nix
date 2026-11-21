{
  config,
  pkgs,
  lib,
  _class,
  ...
}:
{
  home-manager.users.${config.user.username} = {
    programs.zsh.plugins = [
      {
        name = pkgs.tailscale.pname;
        src = "${pkgs.tailscale}/share/zsh/site-functions";
      }
    ];
  };
}
// lib.optionalAttrs (_class == "darwin") {
  homebrew.casks = [ "tailscale-app" ];
  menuBar.hiddenApps = [ "io.tailscale.ipn.macsys" ];

  system.defaults.CustomUserPreferences."io.tailscale.ipn.macsys".HideDockIcon = true;
}
