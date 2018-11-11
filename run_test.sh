#!/bin/bash

METRICS="inst_per_warp,global_hit_rate,local_hit_rate,tex_cache_hit_rate,l2_tex_read_hit_rate,l2_tex_write_hit_rate,gld_efficiency,gst_efficiency,stall_inst_fetch,stall_exec_dependency,stall_memory_dependency,ipc,sm_efficiency"

EVENTS="fb_subp0_read_sectors,fb_subp1_read_sectors,fb_subp0_write_sectors,fb_subp1_write_sectors,l2_subp0_write_sector_misses,l2_subp1_write_sector_misses,l2_subp0_read_sector_misses,l2_subp1_read_sector_misses,l2_subp0_read_tex_sector_queries,l2_subp1_read_tex_sector_queries,l2_subp0_write_tex_sector_queries,l2_subp1_write_tex_sector_queries,l2_subp0_read_tex_hit_sectors,l2_subp1_read_tex_hit_sectors,l2_subp0_write_tex_hit_sectors,l2_subp1_write_tex_hit_sectors,l2_subp0_total_read_sector_queries,l2_subp1_total_read_sector_queries,l2_subp0_total_write_sector_queries,l2_subp1_total_write_sector_queries,elapsed_cycles_sm,generic_load,generic_store,global_load,global_store,local_load,local_store"

TIMESTAMP=$(date +%s)
INPUT="input-hard"

APP="./0123HomeWork"

BLOCKS=( 80 64 32 16 8 4 2 1 )
THREADS=( 256 128 64 32 16 8 4 2 1)

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
        for run in $(seq 1 5);
        do
            echo "run number $run for $i $j";
            /usr/local/cuda/bin/nvprof --unified-memory-profiling per-process-device --log-file $MEM_DIR/$i-$j-$run.out $APP $i $j < $INPUT
            /usr/local/cuda/bin/nvprof --events $EVENTS --log-file $EVENTS_DIR/$i-$j-$run.out $APP $i $j < $INPUT
            /usr/local/cuda/bin/nvprof --metrics $METRICS --log-file $METRICS_DIR/$i-$j-$run.out $APP $i $j < $INPUT
        done;
    done;
done
