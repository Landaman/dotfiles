{ ... }:
{
  boot.zfs.forceImportRoot = false;

  boot.kernel.sysctl = {
    "kernel.panic" = 5;
  };
}
