# Remove personal information from files acquired from iTunes Store

Since the beginning of times, music was ment to be shared.

But, if you acquired music from iTunes Store, either as a direct buy or through the
amazing [iTunes Match service](http://www.apple.com/itunes/itunes-match/), be aware that
your M4A files contain personal information.

## The proof
Use ```exiftool``` to inspect an M4A file:

```console
$ exiftool -UserID -TransactionID -ItemID -AppleStoreCatalogID -AppleStoreAccount -UserName some-itunes-acquired-music-file.m4a
User ID                         : 0x12345678
Transaction ID                  : 0xabcdef98
Item ID                         : 0x34e6b89a
Apple Store Catalog ID          : 9876543210
Apple Store Account             : some@email.com
User Name                       : Avi Alkalay
```

This is unacceptable.

## How to remove this info ?

There is no official music tagger that totally cleans this information. So currently there
are 3 ways to clean this mess:

1. Transcode files to another music format or even to AAC/M4A. This is lossy and
unacceptable.
2. Use [```ffmpeg``` in ```copy``` mode](#for-the-curious-the-ffmpeg-method-discouraged)
to rewrite the files without transcoding (lossless), but loosing header info. You'll have
to retag your files.
3. Do the right thing and cirurgicaly delete only the offending bytes on the file's header

The method implemented by the ```un-istore.sh``` script is #3.

Simply run it in the root folder of you music. It will recursively seek for all offending
M4A files and clean them up. Provide 2 parameters to the script:

1. Your user name as it appears in the music files. Something like "**Your Name**".
2. Your Apple user ID, which is an e-mail address as "**something@email.com**".

Like this:

```console
$ cd MyMusic
$ un-istore.sh "Avi Alkalay" "some@email.com" | tee -a /tmp/un-istore.log
```

**Try it first on an external copy of your music files, before using it directly on your
beloved music collection.**

The script works on Linux and might work on macOS too (use your Mac terminal to run it).

## The proof it worked
Use ```exiftool``` to inspect an M4A file:

```console
$ exiftool -UserID -TransactionID -ItemID -AppleStoreAccount -AppleStoreCatalogID -UserName some-itunes-acquired-music-file.m4a
User ID                         : 0xffffffff
Transaction ID                  : 0xffffffff
Item ID                         : 0x34e6b89a
Apple Store Catalog ID          : 9876543210
Apple Store Account             : iTunes Store
User Name                       : iTunes Store
```

Compare it with the [dirty example above](#the-proof). Catalog ID and Item ID are kept because they are not private information and they help with metadata when sharing music through iMessage.

You can also use the ```check-istore.sh``` script to recursively check all your files. It
will point you the files that are still dirty. But there will be none. I wrote
the ```check-istore.sh``` script while developing ```un-istore.sh``` to check its
effectiveness. It is unneeded anymore but I keep it here for the records.

## The magic

The ```un-istore.sh``` shell script contains a powerful perl script that cirurgically
changes only the 20 or 30 offending bytes on your files. No more, no less. [See for
yourself the simplicity an powerfulness](https://github.com/avibrazil/un-istore/blob/master/un-istore.sh)
of its regular expressions.

## For the curious: The ```ffmpeg``` method (discouraged)

The ```un-istore.sh``` script is faster and superior than the ```ffmpeg``` in ```copy```
mode method documented in this section. But if you are just curious about it, here it is:

```shell
mkdir clean;

ls *m4a | while read f; do
	ffmpeg -i "$f" -acodec copy -vn "clean/$f" < /dev/null;
done
```

After running this, a cleaned up version of your files will be under ```clean``` folder.
```ffmpeg``` will completely rewrite your files (forgetting obscure tags as the ones
we want to delete) while ```-acodec copy``` guarantees a plain copy (and not transcoding) 
in the audio level. You will loose some of your tags and cover art too, though. So retag
your new files after that.

Use ```un-istore.sh``` provided in this repository for a faster and more precise fix.
