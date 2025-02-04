{
  pkgs,
}:
with pkgs;
writeShellApplication {
  name = "tmux-session";

  runtimeInputs = [
    tmux
    fzf
    zoxide
  ];

  text = ''
    #!/usr/bin/env bash

    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(zoxide query --list | fzf || true)
    fi

    if [[ -z $selected ]]; then
        exit 0
    fi

    selected_name=$(basename "$selected" | tr ." " _)
    tmux_running=$(pgrep tmux || true) 

    if [[ -z ''${TMUX:-} ]]; then
        if [[ -z $tmux_running ]]; then
            tmux new-session -s "$selected_name" -c "$selected"
            exit 0;
        elif ! tmux has-session -t="$selected_name" 2> /dev/null; then
            tmux new-session -ds "$selected_name" -c "$selected"
        fi

        tmux attach-session -t "$selected_name"
    else
        if ! tmux has-session -t="$selected_name" 2> /dev/null; then
            tmux new-session -ds "$selected_name" -c "$selected"
        fi

        tmux switch-client -t "$selected_name"
    fi
  '';
}
