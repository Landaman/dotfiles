{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openjdk
    maven
  ];
}
