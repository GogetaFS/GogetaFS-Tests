# Test suite for GogetaFS atop SSD

This repository contains the test suite for GogetaFS atop SSD. The thorough artifact evaluation steps can be obtained from [GogetaFS-AE](https://github.com/GogetaFS/GogetaFS-AE). 

To use this test suite, we follow the steps below:

- We reproduce the Z-SSD results using [FEMU](git@github.com:MoatLab/FEMU.git) environment. 

- We install a Ubuntu 20.04 LTS image with the kernel version 5.4.0-189-generic. 

- We modify femu/build-femu/run-nossd.sh to run the Z-SSD experiments:

    ```bash
    #!/bin/bash
    # Huaicheng Li <huaicheng@cs.uchicago.edu>
    # Run FEMU with no SSD emulation logic, (e.g., for SCM/Optane emulation)

    # Image directory
    IMGDIR=$HOME/
    # Virtual machine disk image
    OSIMGF=$IMGDIR/ub20.qcow2


    if [[ ! -e "$OSIMGF" ]]; then
        echo ""
        echo "VM disk image couldn't be found ..."
        echo "Please prepare a usable VM image and place it as $OSIMGF"
        echo "Once VM disk image is ready, please rerun this script again"
        echo ""
        exit
    fi

    # enable performance mode
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

    sudo ./qemu-system-x86_64 \
        -name "FEMU-NoSSD-VM" \
        -enable-kvm \
        -cpu host \
        -smp 36 \
        -m 32G \
        -device virtio-scsi-pci,id=scsi0 \
        -device scsi-hd,drive=hd0 \
        -drive file=$OSIMGF,if=none,aio=native,cache=none,format=qcow2,id=hd0 \
        -device femu,queues=64,devsz_mb=32768,id=nvme0 \
        -net user,hostfwd=tcp::2333-:22 \
        -net nic,model=virtio \
        -nographic \
        -qmp unix:./qmp-sock,server,nowait
    ```

- Inside femu, using `scp` to copy `GogetaFS-AE/SSD-emu/*` to the VM, supposing the directory is `/home/user/SSD-emu`.

- Run the following commands to reproduce the Z-SSD results:

    ```bash
    cd /home/user/SSD-emu/GogetaFS-Tests
    bash run_all.sh
    ```
- The final figures should be stored in the `/home/user/SSD-emu/GogetaFS-Tests/FIG_FIO/FIG-Port.pdf`.