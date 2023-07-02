#!/usr/bin/env bash

read -p 'Node name (i|d): ' name

secret=monkey

cmd='iex --sname "${name}" --cookie "${secret}" -S mix phx.server'

# https://github.com/jetpack-io/devbox/issues/1142
# https://github.com/jetpack-io/devbox/issues/1055
# cmd='iex --sname "${name}" --cookie "${secret}" -S /nix/store/d0dha8faqppap6wl9b8ykml6jskahyhl-elixir-1.14.4/bin/mix phx.server'

SESSION="LiveCue"
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

if [ "$SESSIONEXISTS" = "" ]
then
	tmux new-session -d -s $SESSION

	tmux rename-window -t 0 'Main'
	tmux send-keys -t 'Main' 'cmus' C-m
	tmux send-keys -t 'Main' '4'

	tmux split-window -h "$cmd"
fi

tmux attach-session -t $SESSION:0
