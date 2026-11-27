# Serve the physical Hyprland session through noVNC on the tailnet
{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.user.username;
  sockets = "/run/physical-remote-desktop";
  vncSocket = "${sockets}/vnc.sock";
  webSocket = "${sockets}/web.sock";

  # Allow noVNC's Apple DH authentication, with HTTPS providing the transport encryption
  wayvncConfig = pkgs.writeText "physical-wayvnc.conf" ''
    enable_auth=true
    enable_pam=true
    relax_encryption=true
  '';

  lockWatcher = "${lib.getExe pkgs.python3} ${./remote-desktop-lock.py}";
in
{
  security.pam.services.wayvnc.rules.account.desktop-user = {
    order = config.security.pam.services.wayvnc.rules.account.unix.order - 10;
    control = "required";
    modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
    args = [
      "user"
      "="
      user
      "quiet"
    ];
  };

  systemd.tmpfiles.rules = [ "d ${sockets} 0700 ${user} - -" ];

  services.tailscale.machineServe."8443" = {
    target = "unix:${webSocket}";
    depends = [ "physical-novnc.service" ];
  };

  systemd.services.physical-novnc = {
    description = "Serve noVNC for the physical desktop";
    serviceConfig = {
      User = user;
      UMask = "0077";
      ExecStart = "${lib.getExe pkgs.python3Packages.websockify} --web ${pkgs.novnc}/share/webapps/novnc --unix-listen ${webSocket} --unix-target ${vncSocket} --heartbeat 15";
      Restart = "on-failure";
    };
  };

  home-manager.users.${user}.systemd.user.services = {
    physical-wayvnc = {
      Unit = {
        Description = "Share the physical Hyprland session through WayVNC";
        After = [
          "wayland-session-waitenv.service"
          "hyprlock.service"
        ];
        PartOf = [ "graphical-session.target" ];
        Wants = [ "physical-wayvnc-lock.service" ];
      };
      Service = {
        ExecStartPre = "${lib.getExe' pkgs.coreutils "rm"} -f ${vncSocket}";
        ExecStart = "${lib.getExe pkgs.wayvnc} --config ${wayvncConfig} --socket %t/physical-wayvnc/ctl --output eDP-1 --unix-socket ${vncSocket}";
        RuntimeDirectory = "physical-wayvnc";
        UMask = "0077";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    physical-wayvnc-lock = {
      Unit = {
        Description = "Unlock for authenticated WayVNC viewers and restore the lock on disconnect";
        After = [ "physical-wayvnc.service" ];
        BindsTo = [ "physical-wayvnc.service" ];
        PartOf = [ "physical-wayvnc.service" ];
      };
      Service = {
        Environment = [
          "PATH=${
            lib.makeBinPath [
              config.programs.hyprland.package
              pkgs.systemd
              pkgs.wayvnc
            ]
          }"
        ];
        ExecStart = "${lockWatcher} watch %t/physical-wayvnc/ctl";
        ExecStopPost = "${lockWatcher} restore";
        RuntimeDirectory = "physical-wayvnc-lock";
        RuntimeDirectoryPreserve = "restart";
        UMask = "0077";
        Restart = "on-failure";
        RestartSec = "1s";
      };
    };
  };
}
