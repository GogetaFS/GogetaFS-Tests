#!/usr/bin/env bash

# shellcheck source=/dev/null
source "../common.sh"
ABS_PATH=$(where_is_script "$0")
mkdir -p "$ABS_PATH"/M_DATA

FILE_SYSTEMS=( "f2fs" "GogetaFS" "GogetaFS" "GogetaFS" "GogetaFS" )
TIMERS=( "fio_f2fs_trace_no_sync.sh" "fio_f2fs_trace_no_sync.sh" "fio_f2fs_trace_no_sync.sh" "fio_f2fs_trace_no_sync.sh" "fio_f2fs_trace_no_sync.sh" )
SETUPS=( "setup_f2fs.sh" "setup_f2fs.sh" "setup_f2fs.sh" "setup_f2fs.sh" "setup_f2fs.sh" )
BRANCHES=( "main" "hfdedup" "smartdedup" "main" "lightdedup" )

# TODO: regulate dup ratio
# dup ratio: 62.5%, 80%, 53.4%, 70%
NAMES=( "homes" "os" "web" "mail")
TRACES=( "69" "84" "47" "95" )
WRITE_RATIO=( "100" "100" "78" "91" )

MAX_C_BLKS=( 1  )
NUM_JOBS=( 1 )

TABLE_NAME="$ABS_PATH/performance-comparison-table-no-sync"
table_create "$TABLE_NAME" "file_system trace cblks job bandwidth(MiB/s)"

loop=1
if [ "$1" ]; then
    loop=$1
fi

echo 4 > /proc/sys/vm/dirty_ratio
# start commit pages when 600M
echo 2 > /proc/sys/vm/dirty_background_ratio

for ((i=1; i <= loop; i++))
do
    for cblks in "${MAX_C_BLKS[@]}"; do
        for job in "${NUM_JOBS[@]}"; do
            STEP=0
            for file_system in "${FILE_SYSTEMS[@]}"; do
                TRACE_ID=0
                for TRACE in "${TRACES[@]}"; do
                    echo 1 > /proc/sys/vm/drop_caches
                    echo 2 > /proc/sys/vm/drop_caches
                    echo 3 > /proc/sys/vm/drop_caches
                    sleep 1

                    TIMER=${TIMERS[$STEP]}
                    SETUP=${SETUPS[$STEP]}
                    dup_rate=${TRACES[$TRACE_ID]}
                    fsize=1024
                    wr_ratio=${WRITE_RATIO[$TRACE_ID]}
                    
                    EACH_SIZE=$(split_workset "$fsize" "$job")
                    BW=$(bash ../TOOLS/"$TIMER" "$file_system" "$job" "${EACH_SIZE}"M "$dup_rate" "${BRANCHES[$STEP]}" "0" 4k 1 $wr_ratio | grep WRITE: | awk '{print $2}' | sed 's/bw=//g' | ../TOOLS/to_MiB_s)
                    

                    table_add_row "$TABLE_NAME" "$file_system-${BRANCHES[$STEP]} ${NAMES[$TRACE_ID]} $cblks $job $BW"  
                    TRACE_ID=$((TRACE_ID + 1))
                done
                STEP=$((STEP + 1))
            done
        done
    done
done

echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio