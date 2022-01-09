# Einstellungen für bestimmte Scanner ermitteln

```
$> scanimage -L
```

## Futjitsu ScanSnap s1300i

```
$> scanimage --device-name='epjitsu:libusb:001:018' -A

All options specific to device `epjitsu:libusb:001:018':
  Scan Mode:
    --source ADF Front|ADF Back|ADF Duplex [ADF Front]
        Selects the scan source (such as a document-feeder).
    --mode Lineart|Gray|Color [Lineart]
        Selects the scan mode (e.g., lineart, monochrome, or color).
    --resolution 50..600dpi (in steps of 1) [300]
        Sets the resolution of the scanned image.
  Geometry:
    -t 0..289.353mm (in steps of 0.0211639) [0]
        Top-left y position of scan area.
    --page-width 2.70898..219.428mm (in steps of 0.0211639) [215.872]
        Specifies the width of the media.  Required for automatic centering of
        sheet-fed scans.
    --page-height 0..450.707mm (in steps of 0.0211639) [292.062]
        Specifies the height of the media, 0 will auto-detect.
  Enhancement:
    --brightness -127..127 (in steps of 1) [0]
        Controls the brightness of the acquired image.
    --contrast -127..127 (in steps of 1) [0]
        Controls the contrast of the acquired image.
    --threshold 0..255 (in steps of 1) [120]
        Select minimum-brightness to get a white point
    --threshold-curve 0..127 (in steps of 1) [55]
        Dynamic threshold curve, from light to dark, normally 50-65
  Sensors:
    --scan[=(yes|no)] [no] [hardware]
        Scan button
    --page-loaded[=(yes|no)] [no] [hardware]
        Page loaded
    --top-edge[=(yes|no)] [no] [hardware]
        Paper is pulled partly into adf
    --cover-open[=(yes|no)] [no] [hardware]
        Cover open
    --power-save[=(yes|no)] [yes] [hardware]
        Scanner in power saving mode


scanimage: rounded value of page-width from 205 to 204.994
scanimage: rounded value of page-height from 296 to 295.999
```

## HP OfficeJet Pro 8600

```
$> scanimage --device-name='hpaio:/usb/Officejet_Pro_8600?serial=CN2C1CXJGN05KC' -A

All options specific to device `hpaio:/usb/Officejet_Pro_8600?serial=CN2C1CXJGN05KC':
  Scan mode:
    --mode Lineart|Gray|Color [Lineart]
        Selects the scan mode (e.g., lineart, monochrome, or color).
    --resolution 75|100|200|300dpi [75]
        Sets the resolution of the scanned image.
    --source Flatbed|ADF [Flatbed]
        Selects the scan source (such as a document-feeder).
  Advanced:
    --brightness 0..2000 [1000]
        Controls the brightness of the acquired image.
    --contrast 0..2000 [1000]
        Controls the contrast of the acquired image.
    --compression None|JPEG [None]
        Selects the scanner compression method for faster scans, possibly at
        the expense of image quality.
    --jpeg-quality 0..100 [inactive]
        Sets the scanner JPEG compression factor. Larger numbers mean better
        compression, and smaller numbers mean better image quality.
  Geometry:
    -l 0..215.9mm [0]
        Top-left x position of scan area.
    -t 0..297.011mm [0]
        Top-left y position of scan area.
    -x 0..215.9mm [215.9]
        Width of scan-area.
    -y 0..297.011mm [297.011]
        Height of scan-area.
```
