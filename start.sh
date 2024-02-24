#!/usr/bin/env bash

source ./envs/.env.all

ip_address=`sudo zerotier-cli get ${NETWORK_ID} ip4`
name="livecue@${ip_address}"

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
