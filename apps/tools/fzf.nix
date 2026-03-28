{
  config,
  lib,
  ...
}:
let
  username = config.user.username;
in
{
  home-manager.users.${username}.programs.fzf = rec {
    enable = true;
    defaultCommand = ''
      fd --type f --follow --strip-cwd-prefix --color=never --hidden ${
        lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") config.files.neverShowGlobs
      }
    '';
    fileWidgetCommand = "${defaultCommand}";
    changeDirWidgetCommand = ''
      fd --type d --follow --color=never --hidden ${
        lib.concatMapStringsSep " " (globPattern: "--exclude=${globPattern}") config.files.neverShowGlobs
      }
    '';
    defaultOptions = [
      "--multi"
    ];
  };
}
