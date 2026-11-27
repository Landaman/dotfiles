{
  config,
  flake,
  lib,
  pkgs,
  _class,
  ...
}:
let
  socket = "/run/rex-headless/serve.sock";
in
lib.mkMerge [
  {
    home-manager.sharedModules = [ flake.inputs.rex.homeManagerModules.default ];

    home-manager.users.${config.user.username} = {
      programs.rex = {
        enable = true;
        package = pkgs.rex;
        sshGuard = false; # SSH is not currently managed in this flake
      };
    };
  }
  (lib.optionalAttrs (_class == "nixos") (
    lib.mkIf config.headless.enable {
      systemd.tmpfiles.rules = [ "d /run/rex-headless 0700 ${config.user.username} - -" ];

      services.tailscale.machineServe."7297".target = "unix:${socket}";

      home-manager.users.${config.user.username}.services.rex = {
        enable = true;
        extraListen = [ "tailnet-serve://${socket}" ];
        # Tagged Tailscale hosts have no owner to authorize by default
        extraArgs = [ "--tailnet-allow-identified" ];
      };
    }
  ))
]
