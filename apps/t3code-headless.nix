{
  config,
  lib,
  pkgs,
  ...
}:
let
  username = config.user.username;
  port = 3773;
in
{
  networking.firewall.allowedTCPPorts = [ port ];

  home-manager.users.${username}.systemd.user.services.t3code = {
    Unit.Description = "T3 Code headless server";
    Service = {
      ExecStart = "${lib.getExe' pkgs.t3code "t3"} serve --lan --port ${toString port}";

      # Copied from the T3 Code "t3 up" service
      WorkingDirectory = "%h";
      KillMode = "mixed";
      OOMPolicy = "continue";
      CPUWeight = 1000;
      IOWeight = 1000;
      MemoryLow = "1536M";
      OOMScoreAdjust = 100;
      ManagedOOMPreference = "avoid";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
