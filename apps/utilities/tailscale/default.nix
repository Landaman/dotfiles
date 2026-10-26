# Select platform module imports from Nix's built-in module class
{ _class, ... }:
{
  imports = [
    (if _class == "darwin" then ./darwin.nix else ./linux.nix)
  ];
}
