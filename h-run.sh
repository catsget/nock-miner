#!/bin/bash

cd `dirname $0`

source colors
source h-manifest.conf
source $CUSTOM_CONFIG_FILENAME

[[ -z $CUSTOM_LOG_BASENAME ]] && echo -e "${RED}No CUSTOM_LOG_BASENAME is set${NOCOLOR}" && exit 1
[[ ! -f $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}Config $CUSTOM_CONFIG_FILENAME not found${NOCOLOR}" && exit 1

CUSTOM_LOG_BASEDIR=`dirname "${CUSTOM_LOG_BASENAME}"`
[[ ! -d $CUSTOM_LOG_BASEDIR ]] && mkdir -p $CUSTOM_LOG_BASEDIR

CMD="./golden-miner-pool-prover --pubkey=$PUBKEY"

[[ -n "$GPU_LIST" ]] && CMD="$CMD --gpu=$GPU_LIST"
[[ -n "$MODE" ]] && CMD="$CMD --mode=$MODE"
[[ -n "$PROXY" ]] && CMD="$CMD --proxy=$PROXY"
[[ -n "$LABEL" ]] && CMD="$CMD --label=$LABEL"
[[ -n "$NAME" ]] && CMD="$CMD --name=$NAME"
[[ -n "$THREADS_PER_CARD" ]] && CMD="$CMD --threads-per-card=$THREADS_PER_CARD"

$CMD 2>&1 | tee --append ${CUSTOM_LOG_BASENAME}.log
