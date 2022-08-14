# CPM disk factory

This will allow you to create 64 or 128MB disk images for use with for example
an RC2014, or its [emulator](https://github.com/EtchedPixels/RC2014). The `diskdefs` file contains definitions for both.

Files found in `content/?` will be copied to the corresponding partition.

Some files found under `content/pkg` are created from the [RC2014Z80 CPM IDE
images](https://github.com/RC2014Z80/RC2014/tree/master/ROMs/CPM-IDE/CPM%20Drives),
the contents processed with `filepackage.py`

Other disk targets (`simh` for example) are possible by adding them to the `diskdefs`.

## dependencies

This bash script uses `cpmtools` and a few unixy tools like `awk`, `dd`.
To create a bootable disk I've copied the bootblocks from the
[RC2014Z80](https://github.com/RC2014Z80/RC2014) project images.
I found that cpmtools work better with multi-partition disk images under linux
than osx, YMMV. The script will build the image, but after that manually
copying to anything but the a: disk won't work.

## populating the disks

The directory `content` contains directories a-p for each partition. The
scripts will copy the content of each directory to the corresponding partition

Keep in mind that the last partition is 2MB, h: for a 64MB and p: for a 128MB
image.

The n: and o: disks will have some DOWNLOAD packages available

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

## bugs

* the content/[a-z] directories have a dot-file `.git_placeholder`. It's a hack
for git. Consequently, the script will ignore dot-files. They would show up in
CP/M as a file with only an extention.
* not a bug: script will overwrite anything with the name CPM128.img, CPM64.img
and cfdisk.ide. It's a factory.

# TODO

Maybe a script to create a `content` directory from an existing image, as kind
of a backup


