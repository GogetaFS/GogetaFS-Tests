#!/usr/bin/env bash

cd TOOLS || exit

make 

cd ..


loops=$1

# FIG_FIO
cd FIG_FIO || exit
bash test.sh "$loops"
bash test-no-sync.sh "$loops"

bash agg.sh "$loops"

# FIG_RealWorld

cd ../FIG_RealWorld || exit
bash test.sh "$loops"
bash test-no-sync.sh "$loops"

bash agg.sh "$loops"

# draw
cd ../FIG_FIO || exit
ipython -c "%run plot.ipynb"
