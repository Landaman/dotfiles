{
  pkgs,
  neverIgnore,
  ignore,
  alwaysIgnore,
}:
with pkgs;
writeShellApplication {
  name = "rgi";

  runtimeInputs = [
    ripgrep
  ];

  text = ''
    #!/usr/bin/env bash

    filtered_args=()

    for arg in "$@"; do
        # Check if the arg is any of the possible ignores, don't do anything with it if so
        ignore_regex='^--ignore(?:-(?:case|dot|exclude|file-case-insensitive|files|global|parent|vcs))?$'
        if [[ "$arg" =~ $ignore_regex ]]; then
            continue
        fi

        if [[ "$arg" == --ignore-file=* ]]; then
            continue
        fi
        
        filtered_args+=("$arg")
    done

    # Surpress warnings about no files searched
    rg "''${filtered_args[@]}" -uuu --ignore-file=${neverIgnore} --no-messages || true


    no_ignore_regex='\B(?:--no-ignore|-u+|--unrestricted)\b'

    if [[ $* =~ $no_ignore_regex ]]; then
      rg "$@" --ignore-file=${alwaysIgnore}
    else
      rg "$@" --ignore-file=${ignore} --ignore-file=${alwaysIgnore}
    fi
  '';
}
