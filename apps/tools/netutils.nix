{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    wget
  ];
  homebrew.brews = [ "inetutils" ];
}
