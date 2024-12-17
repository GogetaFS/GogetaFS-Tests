if [ ! $3 ]; then
	echo Usage: "$0" fs_dir branch_name measure_timing
	exit 1
fi

ABSPATH=$(cd "$( dirname "$0" )" && pwd)

fs_dir=$1
branch_name=$2

cd "$ABSPATH"/../../"$fs_dir"/ || exit

git checkout "$branch_name"
make -j32
sudo bash -c "echo $0 $* > /dev/kmsg"

sudo bash setup.sh /dev/nvme0n1 /mnt/nvme0n1

cd - || exit

