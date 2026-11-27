# Provide a Hyprland desktop while SSH and agent workloads stay independent of it
{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Keep the headless instance separate and its IPC socket paths within Linux's 107-byte limit
  headlessRuntimeDirectory = "ah";

  # Weston listens on this socket for the nested Hyprland session
  headlessSocketName = "wayland-headless-backend";

  # Aquamarine 0.16 binds hardcoded protocol versions that headless Weston does not advertise
  headlessAquamarine = pkgs.aquamarine.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + "\n"
      + ''
        substituteInPlace src/backend/Wayland.cpp \
          --replace-fail "&wl_seat_interface, 9)" "&wl_seat_interface, std::min(version, 9U))" \
          --replace-fail "&xdg_wm_base_interface, 6)" "&xdg_wm_base_interface, std::min(version, 6U))" \
          --replace-fail "&wl_compositor_interface, 6)" "&wl_compositor_interface, std::min(version, 6U))"
      '';
  });
  # The protocol fix keeps the library ABI and can reuse the cached Hyprland build
  headlessHyprland = pkgs.replaceDependency {
    drv = pkgs.hyprland;
    oldDependency = pkgs.aquamarine;
    newDependency = headlessAquamarine;
  };

  headlessHyprlandConfig = pkgs.writeText "headless-hyprland.lua" ''
    hl.config({ misc = { disable_hyprland_logo = true, disable_splash_rendering = true } })
    hl.monitor({ output = "", mode = "1920x1080@60", position = "auto", scale = 1 })
    hl.on("hyprland.start", function()
      hl.exec_cmd("${lib.getExe' headlessHyprland "hyprctl"} output create headless")
    end)
  '';

  hyprlandSession = "${lib.getExe config.programs.uwsm.package} start hyprland.desktop";
in
lib.mkMerge [
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
  (lib.mkIf config.headless.enable {
    agents.skills.headless-hyprland = ''
      ---
      name: headless-hyprland
      description: Use the machines headless Hyprland session for desktop computer use
      ---

      # Desktop Automation

      Use the headless Hyprland session for GUI work. Check `systemctl --user
      status headless-hyprland.service` if it is unavailable.

      Set `WAYLAND_DISPLAY="$XDG_RUNTIME_DIR/${headlessRuntimeDirectory}/wayland-1"` for Wayland apps, `grim`,
      and `wtype`. Set `XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR/${headlessRuntimeDirectory}"` for `hyprctl` so it
      discovers the headless instance. Start `wtype` with `-s 600` to give the app time
      to attach to the virtual keyboard.

      Leave the physical desktop locked.
    '';

    home-manager.users.${config.user.username} = {
      home.packages = [ pkgs.wtype ];

      systemd.user.services = {
        headless-hyprland-backend = {
          Unit = {
            Description = "Virtual display backend for headless Hyprland";
            PartOf = [ "headless-hyprland.service" ];
          };
          Service = {
            Type = "notify";
            ExecStart = "${lib.getExe pkgs.weston} --no-config --backend=headless --renderer=gl --shell=kiosk-shell.so --modules=systemd-notify.so --socket=${headlessSocketName} --width=1920 --height=1080";
          };
        };

        headless-hyprland = {
          Unit = {
            Description = "Headless Hyprland desktop for agents";
            Requires = [ "headless-hyprland-backend.service" ];
            After = [ "headless-hyprland-backend.service" ];
          };
          Service = {
            Type = "notify";
            ExecStart = "${lib.getExe' headlessHyprland "Hyprland"} --config ${headlessHyprlandConfig}";
            RuntimeDirectory = headlessRuntimeDirectory;
            RuntimeDirectoryMode = "0700";
            Environment = [
              "XDG_RUNTIME_DIR=%t/${headlessRuntimeDirectory}"
              "WAYLAND_DISPLAY=%t/${headlessSocketName}"
              "HYPRLAND_NO_SD_VARS=1"
            ];
            UnsetEnvironment = "DISPLAY WAYLAND_SOCKET HYPRLAND_INSTANCE_SIGNATURE";
            TimeoutStartSec = "30s";
            TimeoutStopSec = "10s";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "default.target" ];
        };
      };
    };
  })
]
