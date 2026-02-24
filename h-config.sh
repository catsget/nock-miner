#!/usr/bin/env bash

cd `dirname $0`

if [[ $CUSTOM_USER_CONFIG =~ --pubkey(=|[[:space:]]+)([^[:space:]]+) ]]; then
    USER_PUBKEY="${BASH_REMATCH[2]}"
fi

if [[ -z "$USER_PUBKEY" ]]; then
    echo "No pubkey found in custom user config"
    exit 1
fi

if [[ $CUSTOM_USER_CONFIG =~ --proxy(=|[[:space:]]+)([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+) ]]; then
    USER_PROXY="${BASH_REMATCH[2]}"
fi

if [[ $CUSTOM_USER_CONFIG =~ --label(=|[[:space:]]+)([^[:space:]]+) ]]; then
    USER_LABEL="${BASH_REMATCH[2]}"
fi

if [[ $CUSTOM_USER_CONFIG =~ --name(=|[[:space:]]+)([^[:space:]]+) ]]; then
    USER_NAME="${BASH_REMATCH[2]}"
fi

if [[ $CUSTOM_USER_CONFIG =~ --threads-per-card(=|[[:space:]]+)([0-9]+) ]]; then
    USER_THREADS_PER_CARD="${BASH_REMATCH[2]}"
fi

if [[ $CUSTOM_USER_CONFIG =~ --gpu(=|[[:space:]]+)([0-9]+(,[0-9]+)*) ]]; then
    USER_GPU_LIST="${BASH_REMATCH[2]}"
fi

if [[ $CUSTOM_USER_CONFIG =~ --mode(=|[[:space:]]+)(auto|hybrid|gpu) ]]; then
    USER_MODE="${BASH_REMATCH[2]}"
fi


conf=""
conf+="PUBKEY=\"$USER_PUBKEY\""$'\n'
[[ -n "$USER_LABEL" ]] && conf+="LABEL=\"$USER_LABEL\""$'\n'
[[ -n "$USER_NAME" ]] && conf+="NAME=\"$USER_NAME\""$'\n'
[[ -n "$USER_PROXY" ]] && conf+="PROXY=\"$USER_PROXY\""$'\n'
[[ -n "$USER_THREADS_PER_CARD" ]] && conf+="THREADS_PER_CARD=\"$USER_THREADS_PER_CARD\""$'\n'
[[ -n "$USER_GPU_LIST" ]] && conf+="GPU_LIST=\"$USER_GPU_LIST\""$'\n'
[[ -n "$USER_MODE" ]] && conf+="MODE=\"$USER_MODE\""$'\n'


echo "$conf" > $CUSTOM_CONFIG_FILENAME
nf+="MODE=\"$USER_MODE\""$'\n'


echo "$conf" > $CUSTOM_CONFIG_FILENAME
