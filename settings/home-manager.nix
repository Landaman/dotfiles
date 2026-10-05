{ config, catppuccin, ... }:
let
  username = config.user.username;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = {
      imports = [
        ./home.nix
        catppuccin.homeModules.catppuccin
      ];
      home = {
        inherit username;
        homeDirectory = config.users.users.${username}.home;
      };
      targets.darwin = {
        copyApps.enable = true;
        linkApps.enable = false;
      };
    };
  };
}
