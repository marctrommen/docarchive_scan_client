# Scanner Installation and Configuration

## Fujitsu ScanSnap S1300i installieren

### Links

*   [Download `1300i_0D12.nal`](https://github.com/stevleibelt/scansnap-firmware/blob/master/1300i_0D12.nal)
*   [Alternativer Download `1300i_0D12.nal`](http://www.openfusion.net/public/files/1300i_0D12.nal)
*   [Anleitung](http://www.openfusion.net/linux/scansnap_1300i)


### prüfen ob Scanner in Config vorhanden ist

```
root@debianvm:~#  vi /etc/sane.d/epjitsu.conf
```

folgenden Eintrag suchen:

```
 # Fujitsu S1300i
firmware /usr/share/sane/epjitsu/1300i_0D12.nal
usb 0x04c5 0x128d
```

dann Verzeichnis erstellen und Datei kopieren:

```
root@debianvm:~#  mkdir --parents /usr/share/sane/epjitsu
root@debianvm:~#  cp /home/marcus/1300i_0D12.nal /usr/share/sane/epjitsu/.
```

Test durchführen:

```
root@debianvm:~#  scanimage -L
device `epjitsu:libusb:002:003' is a FUJITSU ScanSnap S1300i scanner
```

```
root@debianvm:~# scanimage --device-name='epjitsu:libusb:002:003' -A
Output format is not set, using pnm as a default.

All options specific to device `epjitsu:libusb:002:003':
...
```

### Zugriffsrechte für user `marcus` einstellen

```
root@debianvm:~# ll /dev/bus/usb/002/003
crw-rw-r-- 1 root root 189, 130 17. Okt 09:35 /dev/bus/usb/002/003
```

füge `scanner` group und lokale `udev` Regel hinzu:

```
# Add a scanner group (analagous to the existing lp, cdrom, tape, dialout groups)
root@debianvm:~# groupadd -r scanner
groupadd: Gruppe »scanner« existiert bereits.

# Add myself to the scanner group
root@debianvm:~# usermod --append --groups scanner marcus

# check groups entry
root@debianvm:~#  cat /etc/group | grep -i marcus
scanner:x:109:saned,marcus

# Add a udev local rule for the S1300i
root@debianvm:~# vim /etc/udev/rules.d/99-local.rules
# Add:
# Fujitsu ScanSnap S1300i
ATTRS{idVendor}=="04c5", ATTRS{idProduct}=="128d", MODE="0664", GROUP="scanner", ENV{libsane_matched}="yes"
```

abmelden und dann Linux-VM neu starten.
dann nochmal neu mit user `marcus` anmelden und `test.sh` ausführen:

```
#!/usr/bin/env bash

SCANNER_DEVICE='epjitsu:libusb:002:002'
TARGET_DIRECTORY='/home/marcus'
DOCUMENT_ID='test'
START_PAGE_NUMBER=1
scanimage \
   --device-name=${SCANNER_DEVICE} \
   --batch="${TARGET_DIRECTORY}/${DOCUMENT_ID}_%03d.tiff" \
   --batch-start=${START_PAGE_NUMBER} \
   --format=tiff \
   --source 'ADF Duplex' \
   --mode 'Color' \
   --resolution 300 \
   --brightness 0 \
   --contrast 0 \
   -t 0 \
   --page-width 205 \
   --page-height 296
```

```
root@debianvm:~# 
```

sollte nun funktionieren!

## HP Officejet Pro 8600 installieren

### Links

*   [UbuntuUsers - HPLIP](https://wiki.ubuntuusers.de/HPLIP/)
*   [HP - HPLIP](https://developers.hp.com/hp-linux-imaging-and-printing)
*   [Download HPLIP for Debian](https://sourceforge.net/projects/hplip/files/hplip/3.23.8/hplip-3.23.8.run/download?use_mirror=nchc)


### `HPLIP` installieren

```
root@debianvm:~# 
root@debianvm:~# apt install hplip
```

**Test ausführen**

```
root@debianvm:~# scanimage -L
device `hpaio:/usb/Officejet_Pro_8600?serial=CN2C1CXJGN05KC' is a Hewlett-Packard Officejet_Pro_8600 all-in-one
```

**Zugriffsrechte für user `marcus` einstellen**

```
root@debianvm:~# ll /dev/bus/usb/002/003
crw-rw-r-- 1 root lp 189, 130 17. Okt 09:35 /dev/bus/usb/002/003

# Add myself to the lp group
root@debianvm:~# usermod --append --groups lp marcus

# check groups entry
root@debianvm:~#  cat /etc/group | grep -i marcus
lp:x:7:marcus
scanner:x:109:saned,marcus
```

dann nochmal neu mit user `marcus` anmelden und `test_officejet.sh` ausführen:

```
#!/usr/bin/env bash

SCANNER_DEVICE='hpaio:/usb/Officejet_Pro_8600?serial=CN2C1CXJGN05KC'
TARGET_DIRECTORY='/home/marcus'
DOCUMENT_ID='test'
scanimage \
    --device-name=${SCANNER_DEVICE} \
    --format=tiff \
    --source 'Flatbed' \
    --mode 'Color' \
    --resolution 300 \
    --brightness 1000 \
    --contrast 1000 \
    --compression None \
> "${TARGET_DIRECTORY}/${DOCUMENT_ID}.tiff"
```
