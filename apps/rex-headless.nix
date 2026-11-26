{ config, ... }:
let
  socket = "/run/rex-headless/serve.sock";
in
{
  systemd.tmpfiles.rules = [ "d /run/rex-headless 0700 ${config.user.username} - -" ];

  services.tailscale.machineServe."443".target = "unix:${socket}";

  home-manager.users.${config.user.username}.services.rex = {
    enable = true;
    extraListen = [ "tailnet-serve://${socket}" ];
    # Tagged Tailscale hosts have no owner to authorize by default
    extraArgs = [ "--tailnet-allow-identified" ];
  };
}
