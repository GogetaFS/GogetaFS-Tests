if [ ! $3 ]; then
	echo Usage: $0 fs_dir num_of_threads size dup_rate branch_name measure_timing randseed
	exit 1
fi

ABSPATH=$(cd "$( dirname "$0" )" && pwd)

fs_dir=$1

branch_name=$5
measure_timing=$6

cd "$ABSPATH"/../../"$fs_dir"/ || exit

git checkout "$branch_name"
make -j32
sudo bash -c "echo $0 $* > /dev/kmsg"

sudo bash setup.sh /dev/nvme0n1 /mnt/nvme0n1
bash "$ABSPATH"/helper/fio-trace.sh "$2" "$3" "$4" "$7" "$8" "$9"

cd - || exit

