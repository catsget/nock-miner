#!/usr/bin/env bash

source /hive/miners/custom/golden_miner_hiveos/h-manifest.conf
source "$CUSTOM_CONFIG_FILENAME"

algo="nock"
version="${CUSTOM_VERSION}"
curr_ts=$(date +%s)
LOGFILE="${CUSTOM_LOG_BASENAME}.log"
CUSTOM_CONFIG_FILENAME="${CUSTOM_CONFIG_FILENAME}"
GPU_LIST="${GPU_LIST:-}"

if [[ ! -f "$LOGFILE" ]]; then
    stats=$(jq -nc \
        --arg khs "0" \
        --arg hs_units "hs" \
        --arg uptime "0" \
        --arg ver "$version" \
        --arg algo "$algo" \
        '{"khs":$khs, "hs_units":$hs_units, "uptime":$uptime, "ver":$ver, "algo":$algo}')
    exit 0
fi

ALL_GPUS=$(nvidia-smi --list-gpus 2>/dev/null)

if [[ -z "$GPU_LIST" ]]; then
    GPU_COUNT=$(nvidia-smi -L | wc -l)
    GPU_LIST=$(seq 0 $((GPU_COUNT - 1)) | paste -sd "," -)
fi

declare -a final_hs final_bus final_temp final_fan
TOTAL_SPEED=0.0

idx=0
IFS=',' read -ra gpu_idx_array <<< "$GPU_LIST"
for gpu in "${gpu_idx_array[@]}"; do
    name=$(nvidia-smi -i "$gpu" --query-gpu=name --format=csv,noheader 2>/dev/null)
    name="${name:-n/a}"

    temp=$(nvidia-smi -i "$gpu" --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null)
    temp="${temp:-n/a}"

    fan=$(nvidia-smi -i "$gpu" --query-gpu=fan.speed --format=csv,noheader,nounits 2>/dev/null)
    fan="${fan:-n/a}"

    bus_hex=$(nvidia-smi -i "$gpu" --query-gpu=pci.bus_id --format=csv,noheader 2>/dev/null | cut -d':' -f2)
    bus=$((16#$bus_hex))
    bus="${bus:-0}"

    gpu_speed=$(grep -oE "Card-${idx} speed:[[:space:]]+[0-9]+\.[0-9]+" "$LOGFILE" | awk '{print $3}' | tail -n 1)
    gpu_speed="${gpu_speed:-0}"
    TOTAL_SPEED=$(awk "BEGIN {printf \"%.6f\", $TOTAL_SPEED + $gpu_speed}")

    final_hs+=("$gpu_speed")
    final_bus+=("$bus")
    final_temp+=("$temp")
    final_fan+=("$fan")

    ((idx++))
done

if [[ -f "$CUSTOM_CONFIG_FILENAME" ]]; then
    uptime=$(( $(date +%s) - $(stat -c %Y "$CUSTOM_CONFIG_FILENAME") ))
else
    uptime=0
fi

hash_json=$(printf '%s\n' "${final_hs[@]}" | jq -cs '.')
bus_json=$(printf '%s\n' "${final_bus[@]}" | jq -cs '.')
temp_json=$(printf '%s\n' "${final_temp[@]}" | jq -cs '.')
fan_json=$(printf '%s\n' "${final_fan[@]}" | jq -cs '.')

khs=$(awk "BEGIN {printf \"%.6f\", $TOTAL_SPEED/1000}")

stats=$(jq -nc \
    --argjson hs "$hash_json" \
    --arg hs_units "hs" \
    --arg algo "$algo" \
    --arg ver "$version" \
    --argjson bus_numbers "$bus_json" \
    --argjson temp "$temp_json" \
    --argjson fan "$fan_json" \
    --arg uptime "$uptime" \
    --arg khs "$khs" \
    '{hs: $hs, hs_units: $hs_units, algo: $algo, ver: $ver,
      uptime: ($uptime|tonumber), bus_numbers: $bus_numbers,
      temp: $temp, fan: $fan, khs: ($khs|tonumber)}')

echo "$stats"
