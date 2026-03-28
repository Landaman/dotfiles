{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    coursier
    sbt
  ];
}
