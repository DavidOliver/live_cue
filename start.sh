#!/usr/bin/env bash

read -p 'Node ID (i|d): ' id

read -p 'Node IP address: ' ip

name="${id}@${ip}"
secret='monkey'
erl_options='-kernel inet_dist_listen_min 9001 inet_dist_listen_max 9001'

cmd="iex --name \"${name}\" --cookie \"${secret}\" --erl \"${erl_options}\" -S mix phx.server"

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
