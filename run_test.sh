#!/bin/bash

METRICS="inst_per_warp,branch_efficiency,warp_execution_efficiency,warp_nonpred_execution_efficiency,global_hit_rate,local_hit_rate,tex_cache_hit_rate,l2_tex_read_hit_rate,l2_tex_write_hit_rate,gld_efficiency,gst_efficiency,stall_inst_fetch,stall_exec_dependency,stall_memory_dependency,ipc,sm_efficiency"

TIMESTAMP=$(date +%s)
INPUT="input-hard"

APP="./0123HomeWork"

BLOCKS=( 1 2 4 8 16 32 64 80 )
THREADS=( 1 2 4 8 16 32 64 128 256)

EVENTS_DIR="$TIMESTAMP/events"
MEM_DIR="$TIMESTAMP/memory"
METRICS_DIR="$TIMESTAMP/metrics"

mkdir -p $EVENTS_DIR
mkdir -p $MEM_DIR
mkdir -p $METRICS_DIR

for i in ${BLOCKS[@]};
do
    for j in ${THREADS[@]};
    do
        echo "running for $i $j";
        nvprof --unified-memory-profiling per-process-device --log-file $MEM_DIR/$i-$j.out $APP $i $j < $INPUT
        nvprof --events all --log-file $EVENTS_DIR/$i-$j.out $APP $i $j < $INPUT
        nvprof --metrics $METRICS --log-file $METRICS_DIR/$i-$j.out $APP $i $j < $INPUT
    done;
done
