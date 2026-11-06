{ ... }: {
  imports = [
    ../hardware/asus-gl552vw.nix
    ../settings
    ../settings/headless.nix
    ../settings/wifi.nix
    ../apps/utilities/tailscale
  ];

  system.stateVersion = "26.05";

  services.tailscale.autoConnect.enable = true;

  # Keep the server running with the laptop lid closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
