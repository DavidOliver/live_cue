#!/usr/bin/env bash

read -p 'Node name (i|d): ' name

secret=monkey

cmd='iex --sname "${name}" --cookie "${secret}" -S mix phx.server'

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
