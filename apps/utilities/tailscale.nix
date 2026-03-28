{
  config,
  pkgs,
  ...
}:
{
  homebrew.casks = [ "tailscale-app" ];

  home-manager.users.${config.user.username}.programs.zsh.plugins = [
    {
      name = pkgs.tailscale.pname;
      src = "${pkgs.tailscale}/share/zsh/site-functions";
    }
  ];
}
