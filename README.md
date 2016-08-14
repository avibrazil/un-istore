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

There is no official music tagger that totally cleans this information. So currently there
are 3 ways to clean this mess:

1. Transcode files to another music format or even to AAC/M4A. This is lossy and unacceptable.
2. Use ```ffmpeg``` in ```copy``` mode to rewrite the files without transcoding (lossless), but loosing header info. You'll have to retag your files.
3. Do the right thing and cirurgicaly delete only the offending bytes on the file's header

The method implemented by this script is #3. Simply run the ```un-istore.sh``` script in
the root folder of you music. It will recursively seek for all offending M4A files and
change them. Pass 2 parameters to the script:

1. Your user name as it appears in the music files. Something like "**Your Name**".
2. Your Apple user ID, which is an e-mail address as "**something@email.com**".

Like this:

```console
$ cd MyMusic
$ un-istore.sh "Avi Alkalay" "some@email.com" | tee -a /tmp/un-istore.log
```

The script works on Linux and might work on macOS too (use your Mac terminal to run it).

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

Compare it with the [dirty example above](#the-proof).

You can also use the ```check-istore.sh``` script recursively check all your files. It
will point you the files that are still dirty. But there will be none. I wrote
the ```check-istore.sh``` script while developing ```un-istore.sh``` to check its
effectiveness, is unneeded anymore but I keep it here for the records.

## The magic

The ```un-istore.sh``` shell script contains a powerful perl script that cirurgically
changes only the 20 or 30 offending bytes on your files. No more, no less. [See for
yourself the simplicity an powerfulness](https://github.com/avibrazil/un-istore/blob/master/un-istore.sh)
of its regular expressions.
