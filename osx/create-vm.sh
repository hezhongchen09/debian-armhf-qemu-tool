#!/bin/sh

if [ $# -gt 5 ]
then
    echo "create-vm.sh -i <cd/dvd rom image path> -o <virtual machine disk image path>"
    exit -1
else
    if [[ $1 == "-i" && $3 == "-o" || $1 == "-o" && $3 == "-i" ]]
    then
        if [[ $1 == "-i" && $3 == "-o" ]]
        then
            cd_rom_image_path=$2
            vm_disk_image_path=$4
        else
            cd_rom_image_path=$4
            vm_disk_image_path=$2
        fi

        vm_disk_image_dir="$(dirname "$vm_disk_image_path")"

        wget -P $vm_disk_image_dir http://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu/QEMU_EFI.fd

        dd if=/dev/zero of=$vm_disk_image_dir/flash0.img bs=1m count=64
        dd if=$vm_disk_image_dir/QEMU_EFI.fd of=$vm_disk_image_dir/flash0.img conv=notrunc
        dd if=/dev/zero of=$vm_disk_image_dir/flash1.img bs=1m count=64
        dd if=/dev/zero of=$vm_disk_image_path bs=1m count=8192

        qemu-system-arm -m 1024 -cpu cortex-a7 -M virt -nographic \
            -pflash $vm_disk_image_dir/flash0.img \
            -drive file=$cd_rom_image_path,id=cdrom,if=none,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom \
            -drive if=none,file=$vm_disk_image_path,id=hd0 -device virtio-blk-device,drive=hd0 \
            -netdev user,id=eth0 -device virtio-net-device,netdev=eth0

        exit 0
    else
        echo "create-vm.sh -i <cd/dvd rom image> -o <virtual machine disk image>"
        exit -1
    fi
fi