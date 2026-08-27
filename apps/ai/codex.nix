{
  pkgs,
  config,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.home = {
    file.".codex/AGENTS.md".source = ./AGENTS.md;

    packages = (
      with pkgs;
      [
        chatgpt
        codex
      ]
    );
  };
}
