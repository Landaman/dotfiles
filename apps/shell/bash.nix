{
  config,
  ...
}:
{
  environment.pathsToLink = [ "/share/bash-completion" ];

  home-manager.users.${config.user.username}.programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
      historySize = 10000;
      historyFileSize = 100000;
      shellOptions = [
        "histappend"
        "checkwinsize"
      ];
    };
  };
}
