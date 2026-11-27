# Build the Fedora home server from pinned nixpkgs, secrets, and shared overlays
{
  nixpkgs,
  secrets,
  overlays,
  home-manager,
  catppuccin,
  flake,
}:
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit
      secrets
      nixpkgs
      catppuccin
      flake
      ;
    homeManager = home-manager;
    hostname = "fedora-home-server";
    systemName = "fedora-home-server";
  };
  modules = [
    (
      {
        config,
        pkgs,
        ...
      }:
      {
        nixpkgs.overlays = overlays;
        imports = [
          ../hardware/asus-gl552vw.nix
          ../modules/files.nix
          ../settings
          ../settings/headless.nix
          ../settings/home-manager.nix
          ../settings/wifi.nix
          ../apps/ai
          ../apps/t3code-headless.nix
          ../apps/rex-headless.nix
          ../apps/shell
          ../apps/tools
          ../apps/editors
          ../apps/lang
          ../apps/window/hyprland.nix
          ./fedora-home-server/headless-hyprland.nix
          ../apps/desktop/firefox.nix
          ../apps/utilities/tailscale
        ];

        system.stateVersion = "26.05";

        users.users.${config.user.username} = {
          shell = pkgs.bashInteractive;
          # Keep services and rootless containers running after SSH disconnects
          linger = true;
        };

        services.tailscale.autoConnect.enable = true;

        home-manager.users.${config.user.username} = {
          catppuccin.autoEnable = false;
          home.stateVersion = "26.05";
          programs.codex.context = builtins.readFile ./personal-agents.md;
          programs.claude-code.context = builtins.readFile ./personal-claude.md;
          programs.git.settings.user = {
            name = "Ian Wright";
            email = "49083526+Landaman@users.noreply.github.com";
          };
          programs.jujutsu.settings.user.name = "Ian Wright";
        };

        # Closing the lid locks the desktop while the server stays awake
        services.logind.settings.Login = {
          HandleLidSwitch = "lock";
          HandleLidSwitchExternalPower = "lock";
          HandleLidSwitchDocked = "lock";
        };
        systemd.targets = {
          sleep.enable = false;
          suspend.enable = false;
          hibernate.enable = false;
          hybrid-sleep.enable = false;
        };
      }
    )
  ];
}
