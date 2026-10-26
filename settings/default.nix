# Select platform module imports from Nix's built-in module class
{ _class, ... }:
{
  imports =
    if _class == "darwin" then
      [
        ./mac.nix
        ./homebrew.nix
        ./home-manager.nix
        ./nix.nix
      ]
    else
      [ ./linux ];
}
