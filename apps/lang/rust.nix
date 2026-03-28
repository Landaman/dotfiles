{
  config,
  pkgs,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home.packages = with pkgs; [
    rustfmt
    clippy
    rust-analyzer
  ];

  environment.systemPackages = with pkgs; [
    cargo
    rustc
  ];
}
