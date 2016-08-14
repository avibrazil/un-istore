# Remove personal information from files acquired from iTunes Store

Since the beginning of times, music was ment to be shared.

But, if you acquired music from iTunes Store, either as a direct buy or through the
amazing [iTunes Match service](http://www.apple.com/itunes/itunes-match/), be aware that
your M4A files contain personal information.

## The proof
Use ```exiftool``` to inspect an M4A file:

```console
$ exiftool -UserID -TransactionID -ItemID -AppleStoreAccount -UserName some-itunes-acquired-music-file.m4a
User ID                         : 0x12345678
Transaction ID                  : 0xabcdef98
Item ID                         : 0x34e6b89a
Apple Store Account             : some@email.com
User Name                       : Avi Alkalay
```

This is unacceptable.

## How to remove this info ?

There are 3 ways to clean this mess:

1. Transcode files to another music format or even to AAC/M4A. This is lossy and unacceptable.
2. Use ```ffmpeg``` in ```copy``` mode to rewrite the files without transcoding (lossless), but loosing header info. You'll have to retag your files.
3. Do the right thing and cirurgicaly delete only the offending bytes on the file's header

The method implemented by this script is #3. Simply run the ```un-istore.sh``` script in
the root folder of you music. It will recursively seek for all offending M4A files and
change them. Optionally capture its output for your records.

Like this:

```console
$ cd MyMusic
$ un-istore.sh "Avi Alkalay" "some@email.com" | tee -a /tmp/un-istore.log
```

The script works on Linux and might work on macOS too (use your Mac terminal).

## The proof it worked
Use ```exiftool``` to inspect an M4A file:

```console
$ exiftool -UserID -TransactionID -ItemID -AppleStoreAccount -UserName some-itunes-acquired-music-file.m4a
User ID                         : 0xffffffff
Transaction ID                  : 0xffffffff
Item ID                         : 0xffffffff
Apple Store Account             : iTunes Store
User Name                       : iTunes Store
```

## The magic

The ```un-istore.sh``` shell script contains a powerful perl script that cirurgicaly
changes only the 20 or 30 offending bytes on your files. No more, no less. [See for
yourself the simplicity an powerfulness](https://github.com/avibrazil/un-istore/blob/master/un-istore.sh)
of its regular expressions.
