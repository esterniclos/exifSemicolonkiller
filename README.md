# exifSemicolonkiller
script to remove exif keywords tags that are separated by semicolon instead of commas.

# Requirements
exiftool installed
comm
awk

# Use
./semicolonKiller.sh  folder


# Testing

cp orig/* dataTest/ ; ./semicolonKiller.sh  dataTest/ ; gthumb dataTest

