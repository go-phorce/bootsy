#!/bin/sh
key_dir=$1
efi_dir=$2
output_image_file=$3

if [ $# -ne 3 ]; then
    echo "Usage $0: key_dir efi_dir output_image_file"
    exit 1;
fi

tmpusb=/var/tmp/tmpusb.$$.img

if [ ! -d "$key_dir" ]; then
    echo "Failed to find directory with key files: $key_dir"
    exit 1;
fi

if [ ! -d "$efi_dir" ]; then
    echo "Failed to find directory with EFI files: $efi_dir"
    exit 1;
fi

dd if=/dev/zero of=${output_image_file} bs=512 count=100000
parted ${output_image_file} "mklabel gpt"
parted ${output_image_file} "mkpart primary fat32 1 -1"
parted ${output_image_file} "toggle 1 boot"
parted ${output_image_file} "set 1 bios_grub on"
parted ${output_image_file} "name 1 UEFI"

dd if=/dev/zero of=${tmpusb} bs=512 count=100000
mkfs.fat -n UEFI-Tools ${tmpusb}
mmd -i ${tmpusb} ::/EFI
mmd -i ${tmpusb} ::/EFI/BOOT
mmd -i ${tmpusb} ::/keys
mcopy -i ${tmpusb} ${key_dir}/*.esl ::/keys
mcopy -i ${tmpusb} ${key_dir}/*.auth ::/keys
mcopy -i ${tmpusb} ${efi_dir}/*.efi ::/EFI/BOOT
dd if=${tmpusb} of=${output_image_file} bs=512 count=100000
rm -f ${tmpusb}
exit 0;
