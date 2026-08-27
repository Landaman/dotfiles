{ pkgs, lib, ... }:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin [ "figma" ];
}
