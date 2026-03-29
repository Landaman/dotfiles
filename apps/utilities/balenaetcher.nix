{
  pkgs,
  lib,
  ...
}:
{
  homebrew.casks = lib.mkIf pkgs.stdenv.isDarwin [ "balenaetcher" ];
}
