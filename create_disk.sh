#!/bin/bash
#
# https://sizeof.cat/post/cp-m-development-setup/
#
# objdump -s ROM.HEX | xxd -r - rom
#
# TODO:
# - dd can replace mkfs.cpm to install bootblocks
# - figure out how to get the bootblocks, more
#   reliable than getting them from the images in
#   rc2014-master. Building them from source would
#   be ideal
# - cpmtools with rc2014boot and rc2014disk
#   definitions are implied. Docker would solve it
#   clean.
#

# setup
# map seq output to partition letters
# (there is no partition 0)
l=(dummy a b c d e f g h i j k l m n o p)

cp_content=true

# default bootblock (option 'b <filename>' to select
# bootblock file)
bb="bootblock/bootblock_sio.bin"

# default cf card size 128mb, 16 partitions
# (option '-c64' builds a 8 partition image)
mp=16
bp=8
sp=2

disk_image=CPM128.img
cf_disk_image=cfdisk.ide

# target staging dir
td=src

function usage {
  echo "Usage: $0 [-b <filename>] [-c <64|128>]"
  echo "  -b <filename>  specify 16kb bootblock file"
  echo "                 (default: bootblock_sio.bin)"
  echo "  -c <64|128>    specify cfcard size 64 or 128mb"
  echo "                 (default: 128)"
}

function err {
  echo "ERROR: $1"
  usage
  exit 1
}

while getopts "b:c:" opt; do
  case $opt in
    "b") bb=$OPTARG;;
    "c") (( OPTARG == "64" )) && mp=8 && sp=5 && disk_image=CPM64.img;;
    *) err "invalid option $OPTARG";;
  esac
done
# no need for arguments, but it's good houskeeping
shift $((OPTIND - 1))

[[ -f $bb ]] || err "bootblock $bb not found"

# create work dir and clean up if necessary
mkdir -p $td
rm -f $td/partition_?

echo "creating 1Mb block marked empty"
# nice printf+bash hack
# print 1024*1024 hex E5 bytes, CP/M FS empty
#printf '\xE5%.0s' {1..1048576} > block
#
# but this works too, with mkfs.cpm
dd if=/dev/zero of=block bs=1024 count=1024

# create 8/16 8m partition images from the 1mb block,
# and last one is 2mb. put bootblock on the first one, copy
# files from content subdirs on the images.
# Build $disk_image from partition images in src/
for n in $( seq 1 $mp); do
  # (re)set defaults
  mb=$bp
  # partition letter from number
  p=${l[$n]}

  echo -n "creating partition $p"

  # exceptions
  # last partition is small
  (( n == mp )) && mb=$sp

  echo -n " | size $mb Mb "
  for b in $(seq 1 $mb); do
    cat block
  done > $td/partition_$p

  export CPMTOOLSFMT=rc2014noboot
  # exceptions
  # install bootblock on partition_a
  # last partition is 2mb
  if (( n == 1 )); then
    export CPMTOOLSFMT=rc2014boot
    echo -n " | creating bootable filesystem"
    mkfs.cpm -b $bb -L $p $td/partition_$p
  else
    (( n == mp )) && export CPMTOOLSFMT=rc2014small
    echo -n " | creating filesystem"
    mkfs.cpm -L $p $td/partition_$p
  fi

  [[ $cp_content ]] && (( $(ls content/$p/* 2>/dev/null |wc -l) > 0 )) && \
    echo -n " | populating filesystem" && \
    cpmcp -T raw $td/partition_$p content/$p/* 0:

  echo
done

echo "building disk image: $disk_image"
cat $td/partition_? > $disk_image

# clean up
rm -f block
rm -f ./$td/partition_?

echo "building disk image with ide header: $cf_disk_image"
# fancy dd way:
#cp ideheader.1k $cf_disk_image
#dd if=$disk_image of=$cf_disk_image bs=512 seek=2 conv=notrunc

# but this works too
cat ideheader.1k $disk_image > $cf_disk_image
