{ lib, modulesPath, ... }:
{
  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;

  boot = {
    initrd = {
      systemd.enable = true;

      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usbhid"
        "sd_mod"
      ];

      luks.devices.cryptroot = {
        device = "/dev/disk/by-partlabel/cryptroot";
        crypttabExtraOpts = [ "tpm2-device=auto" ];
      };
    };

    kernelModules = [ "kvm-intel" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  zramSwap.enable = true;
}
