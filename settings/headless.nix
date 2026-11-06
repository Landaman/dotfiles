{
  config,
  secrets,
  systemName,
  ...
}:
{
  imports = [ ../modules/user.nix ];

  user.username = secrets.user.name;
  networking.hostName = systemName;

  services.openssh.enable = true;
  services.timesyncd.enable = true;

  users = {
    mutableUsers = false;
    users.${config.user.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = secrets.user.password;
      openssh.authorizedKeys.keys = secrets.user.sshPublicKeys;
    };
  };

  boot.zfs.forceImportRoot = false;
  boot.kernel.sysctl."kernel.panic" = 5;
}
