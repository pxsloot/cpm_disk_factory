# CPM disk factory

This will allow you to create 64 or 128MB disk images for use with for example
an RC2014, or its [emulator](https://github.com/EtchedPixels/RC2014). The `diskdefs` file contains definitions for both.

Files found in `content/?` will be copied to the corresponding partition.

Other targets (`simh` for example) are possible by adding them to the `diskdefs`.

## dependencies

This bash script uses `cpmtools` and a few unixy tools like `awk`, `dd`.
To create a bootable disk I've copied the bootblocks from the [RC2014Z80](https://github.com/RC2014Z80/RC2014) project.
I found that cpmtools work better under linux than osx, YMMV.

## populating the disks

The directory `content` contains directories a-p for each partition. The
scripts will copy the content of each directory to the corresponding partition

Keep in mind that 64MB disk images have `h:` as last and smaller 2MB partition.

## rc2014 emulator

the RC2014 emulator requires an IDE disk. I've created a disk image the the
`makedisk` tool that comes with the RC2014 emulator source, copied the first 1k
to the `ideheader.1k` file.
To create the required IDE disk image, the script will concat the ide header
and the CPM image.

NB: This is a hack. The IDE header is for a 540MB IDE disk, but the image is
only 64/128MB. The emulator is happy enough with it, so it works for me :-)

## usage

Put everything you want to appear on the image in the `content/[a-p]` directory.
Run the script, use `dd` or `win32image` to put the `CPM128.img` on a cfcard.

Or use the RC2014 emulator with the `cfdisk.ide` image:

`rc2014 -s -r ~/dev/RC2014/ROMs/Factory/24886009.BIN -e 2 -p -i cfdisk.ide`

# TODO

Maybe a script to create a `content` directory from an existing image, as kind
of a backup
