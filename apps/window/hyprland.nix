# Provide a Hyprland desktop while SSH and agent workloads stay independent of it
{
  config,
  pkgs,
  lib,
  ...
}:
let
  hyprlandSession = "${lib.getExe config.programs.uwsm.package} start hyprland.desktop";
in
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = hyprlandSession;
        user = config.user.username;
      };
      default_session.command = "${pkgs.greetd}/bin/agreety --cmd ${lib.escapeShellArg hyprlandSession}";
    };
  };

  security.pam.services.hyprlock = { }; # Generate a PAM service for hyprlock to use for authentication

  home-manager.users.${config.user.username} = {
    home.packages = with pkgs; [
      grim
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "lua";

      # UWSM owns the graphical session environment and service lifetime
      systemd.enable = false;
      extraConfig = ''
        hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
      '';
    };

    programs = {
      fuzzel.enable = true;
      hyprlock = {
        enable = true;
        settings = {
          input-field = {
            monitor = "";
            size = "300, 50";
            position = "0, 0";
            placeholder_text = "Password";
          };
        };
      };
    };

    services.hyprpolkitagent.enable = true;

    services.hypridle = {
      enable = true;
      settings.general.lock_cmd = "${lib.getExe' pkgs.systemd "systemctl"} --user start hyprlock.service";
    };

    systemd.user.services.hyprlock = {
      Unit = {
        Description = "Lock the Hyprland session";
        After = [ "wayland-session-waitenv.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service.ExecStart = lib.getExe pkgs.hyprlock;
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
