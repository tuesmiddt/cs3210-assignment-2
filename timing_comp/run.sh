#!/bin/bash

OMP_BIN="0123HomeWork-openmp"
CU_BIN="0123HomeWork"

PREVIOUS="3210327c68bb9409c4aa5806a4c018e26dcd2ca599a5cbccfaf09c886f701b71"

TIMESTAMP=$(date +%s)

mkdir $TIMESTAMP

echo "making cuda implementation ..."
cd ../cuda
make clean
make

echo "making openmp implementation ..."
cd ../openmp
make clean
make

echo "copying files into current directory"
cd ../timing_comp
cp ../cuda/$CU_BIN .
cp ../openmp/$OMP_BIN .

rm ./*.in

for i in $(seq 48 -1 46);
do
    touch $i.in;
    echo $PREVIOUS > $i.in;
    echo $((2 ** $i)) > $i.in;
    
    for run in $(seq 1 10);
    do
        echo "run number $run, input $i, cuda";
        { time bash -c "./$CU_BIN 80 64 < $i.in > /dev/null"; } 2> "$TIMESTAMP/cu-$i-$run.out";
        echo "run number $run, input $i, omp";
        { time bash -c "./$OMP_BIN 32 < $i.in > /dev/null"; } 2> "$TIMESTAMP/omp-$i-$run.out";
    done;
done
