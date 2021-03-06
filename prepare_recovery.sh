#!/bin/bash

# Written by the-braveknight, based on RehabMan's scripts.

# This script simply installs what's necessary to boot the macOS/OS X recovery to
# EFI/CLOVER. It expects download.sh & install_downloads.sh scripts have already
# been run (kexts present in ./download/kexts).

SUDO=sudo
EFI=`$SUDO ./mount_efi.sh /`
CLOVER=$EFI/EFI/CLOVER
KEXTDEST=$CLOVER/kexts/Other

function install_kext
{
    if [ "$1" != "" ]; then
        echo Installing $1 to $KEXTDEST
        rm -Rf $KEXTDEST/`basename $1`
        cp -Rf $1 $KEXTDEST
    fi
}


# Remove Clover/kexts/10.* folders, keep 'Others' only.
rm -Rf $CLOVER/kexts/10.*
# Remove any kext(s) already present in 'Others' folder.
rm -Rf $KEXTDEST/*.kext


# Install kexts already downloaded by download.sh script
cd ./downloads/kexts
install_kext RehabMan-FakeSMC*/FakeSMC.kext
install_kext RehabMan-IntelMausiEthernet-v2-*/Release/IntelMausiEthernet.kext
install_kext RehabMan-Battery*/Release/ACPIBatteryManager.kext
install_kext RehabMan-FakePCIID/Release/FakePCIID.kext
install_kext RehabMan-FakePCIID/Release/FakePCIID_Broadcom_WiFi.kext
install_kext RehabMan-USBInjectAll-*/Release/USBInjectAll.kexts
cd ../..

# Install PS2 driver that's currently in use.
if [ -e /System/Library/Extensions/VoodooPS2Controller.kext ] || [ -e /Library/Extensions/VoodooPS2Controller.kext ]; then
    install_kext ./downloads/kexts/RehabMan-Voodoo*/Release/VoodooPS2Controller.kext
else
    install_kext ./kexts/ApplePS2SmartTouchPad.kext
fi

# Download & install HFSPlus.efi to CLOVER/drivers64UEFI if it's not present
if [ ! -e $CLOVER/drivers64UEFI/HFSPlus.efi ]; then
    echo Downloading HFSPlus.efi...
    curl https://raw.githubusercontent.com/JrCs/CloverGrowerPro/master/Files/HFSPlus/X64/HFSPlus.efi -o ./downloads/HFSPlus.efi -s
    echo Copying HFSPlus.efi to $CLOVER/drivers64UEFI
    cp ./downloads/HFSPlus.efi $CLOVER/drivers64UEFI
fi

echo Done.
