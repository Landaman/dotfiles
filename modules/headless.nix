{
  config,
  lib,
  _class,
  secrets,
  systemName,
  ...
}:
{
  options.headless.enable = lib.mkEnableOption "headless system settings";

  config = lib.optionalAttrs (_class == "nixos") (
    lib.mkIf config.headless.enable {
      user.username = secrets.user.name;
      networking.hostName = systemName;

      services.openssh.enable = true;
      services.timesyncd.enable = true;
      security.sudo.wheelNeedsPassword = false;

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
  );
}
