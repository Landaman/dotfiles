{
  config,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  options.window = {
    floatingApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Apps that should always open in floating window mode";
    };
  };

  config = {
    home-manager.users.${username}.programs.aerospace = {
      enable = true;
      launchd = {
        enable = true;
        keepAlive = true;
      };
      settings = {
        accordion-padding = 30;
        gaps = {
          outer.left = 0;
          outer.bottom = 0;
          outer.top = 0;
          outer.right = 0;
        };

        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        on-window-detected = (
          map (appId: {
            "if" = {
              app-id = appId;
            };
            run = [ "layout floating" ];
          }) config.window.floatingApps
        );

        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-enter = "exec-and-forget osascript -e '
          if application \"Ghostty\" is running then
            tell application \"System Events\"
              tell application \"Ghostty\" to activate
              keystroke \"n\" using {command down}
            end tell
          else
            tell application \"Ghostty\" to activate
          end if
        '
        ";
          alt-shift-enter = "exec-and-forget osascript -e '
          if application \"Safari\" is running then
            tell application \"Safari\" to make new document
          else
            tell application \"Safari\" to activate
          end if
        '
        ";

          alt-f = "fullscreen";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";
          alt-0 = "balance-sizes";

          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";

          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";

          alt-a = "workspace-back-and-forth";

          alt-tab = "focus-monitor --wrap-around next";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-shift-semicolon = "mode service";

          alt-p = "workspace prev --wrap-around";
          alt-n = "workspace next --wrap-around";
        };
        mode.service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];

          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];
        };
      };
    };
  };
}
