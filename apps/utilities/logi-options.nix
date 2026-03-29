{ pkgs, lib, ... }:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "logi-options+" ];
}
