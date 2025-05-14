#!/bin/env bash
# ******************************************************************************
# Type: Shell Script
# Description: dd Best bs - Block performance testing script with `dd`
# Script Name: dd_best_bs.sh
# Project URL: https://github.com/slackjeff/dd_best_bs/blob/main/dd_best_bs.sh
# ******************************************************************************

set -e  # Stops execution if an error occurs

TEST_FILE=${1:-dd_obs_testfile}
TEST_FILE_SIZE=134217728  # 128 MB
TEST_FILE_EXISTS=0
if [ -e "$TEST_FILE" ]; then TEST_FILE_EXISTS=1; fi

if [ $EUID -ne 0 ]; then
  echo "NOTE: Kernel cache will not be cleared between tests without sudo. This will likely cause inaccurate results." 1>&2
fi

# Header
PRINTF_FORMAT="%-12s %-18s %-18s\n"
printf "\n$PRINTF_FORMAT\n" "Block Size" "Transfer Fee" "Recommended Block"

# List of block sizes and their recommendations
declare -A BLOCK_RECOMMENDATIONS=(
  [512]=512b [1024]=1K [2048]=2K [4096]=4K [8192]=8K [16384]=16K [32768]=32K
  [65536]=64K [131072]=128K [262144]=256K [524288]=512K [1048576]=1M
  [2097152]=2M [4194304]=4M [8388608]=8M [16777216]=16M
  [33554432]=32M [67108864]=64M
)

MAX_TRANSFER_RATE=""
MAX_BLOCK_SIZE=""
MAX_RECOMMENDED_BLOCK=""

for BLOCK_SIZE in "${!BLOCK_RECOMMENDATIONS[@]}"; do
  COUNT=$(($TEST_FILE_SIZE / $BLOCK_SIZE))

  if [ $COUNT -le 0 ]; then
    echo "Block size $BLOCK_SIZE estimated for $COUNT blocks. Stopping testing."
    break
  fi

  # Clear kernel cache (if possible)
  [ $EUID -eq 0 ] && [ -e /proc/sys/vm/drop_caches ] && echo 3 > /proc/sys/vm/drop_caches

  # Perform the writing test with dd
  DD_RESULT=$(dd if=/dev/zero of="$TEST_FILE" bs="$BLOCK_SIZE" count="$COUNT" conv=fsync 2>&1 1>/dev/null)

  # Extract transfer rate from dd
  RAW_TRANSFER_RATE=$(echo "$DD_RESULT" | grep --only-matching -E '[0-9.]+' | head -1)
  UNIT=$(echo "$DD_RESULT" | grep --only-matching -E '([MGk]?B|bytes)/s(ec)?' | head -1)

  # Convert GB to MB to avoid erroneous comparisons
  if [[ "$UNIT" == "GB/s" ]]; then
    RAW_TRANSFER_RATE=$(echo "$RAW_TRANSFER_RATE * 1024" | bc -l)
    UNIT="MB/s"
  fi

  TRANSFER_RATE="$RAW_TRANSFER_RATE $UNIT"

  # Remove the test file if it was created
  if [ $TEST_FILE_EXISTS -ne 0 ]; then rm "$TEST_FILE"; fi

  # Get the recommended block size
  RECOMMENDED_BLOCK="${BLOCK_RECOMMENDATIONS[$BLOCK_SIZE]}"

  # Stores the best result
  if [[ -z "$MAX_TRANSFER_RATE" || $(echo "$RAW_TRANSFER_RATE > $MAX_RAW_TRANSFER_RATE" | bc -l) -eq 1 ]]; then
    MAX_TRANSFER_RATE="$TRANSFER_RATE"
    MAX_RAW_TRANSFER_RATE="$RAW_TRANSFER_RATE"
    MAX_BLOCK_SIZE="$BLOCK_SIZE"
    MAX_RECOMMENDED_BLOCK="$RECOMMENDED_BLOCK"
  fi



  # Display the result
  printf "$PRINTF_FORMAT" "$BLOCK_SIZE" "$TRANSFER_RATE" "$RECOMMENDED_BLOCK"
done

# Displays the best result at the end
echo
echo "-------------------------------------------------------"
echo "Best performance:"
printf "$PRINTF_FORMAT" "$MAX_BLOCK_SIZE" "$MAX_TRANSFER_RATE" "$MAX_RECOMMENDED_BLOCK"