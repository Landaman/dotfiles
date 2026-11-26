{
  lib,
  config,
  ...
}:
{
  services.homebridge = {
    enable = true;
    openFirewall = true;
    # Tailscale Serve owns the tailnet listeners on the same port,
    # so we can only safely bind on localhost
    uiSettings.host = "127.0.0.1";
  };

  # Required so that Homebridge subrouters/service discovery works
  networking.firewall.trustedInterfaces = [ "wlan0" ];

  services.tailscale.tags = lib.mkAfter [ "tag:homebridge" ];
  services.tailscale.machineServe."8581" = {
    target = "http://localhost:${toString config.services.homebridge.uiSettings.port}";
    depends = [ "homebridge.service" ];
  };
}
