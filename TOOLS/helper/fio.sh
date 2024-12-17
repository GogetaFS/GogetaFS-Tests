if [ ! $3 ]; then
	echo Usage: $0 num_of_threads size dup_rate [block_size] [nr_files]
	exit 1
fi


if [ $4 ]; then
	bs=$4
else
	bs=4K
fi

if [ $5 ]; then
	nrfiles=$5
else
	nrfiles=1
fi

sudo fio -directory=/mnt/nvme0n1 -fallocate=none -iodepth 1 -rw=write -ioengine=sync -bs=$bs -thread -numjobs=$1 -size=$2 -name=test --dedupe_percentage=$3 -nrfiles=$nrfiles -group_reporting -fsync=1 -runtime=10s
