#!/bin/bash

PREVIOUS="3210327c68bb9409c4aa5806a4c018e26dcd2ca599a5cbccfaf09c886f701b71"

for i in $(seq 48 -1 30);
do
    touch $i.in;
    echo $PREVIOUS >> $i.in;
    echo $((2 ** $i)) >> $i.in;
done
