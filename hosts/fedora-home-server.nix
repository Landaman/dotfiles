{ ... }: {
  imports = [
    ../hardware/asus-gl552vw.nix
    ../common.nix
  ];

  system.stateVersion = "26.05";

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
