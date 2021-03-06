#! /system/bin/sh

WIFION=`getprop init.svc.p2p_supplicant`

case "$WIFION" in
  "running") echo " ****************************************"
             echo " * Turning Wi-Fi OFF before calibration *"
             echo " ****************************************"
             svc wifi disable
             rmmod wl12xx_sdio;;
          *) echo " ******************************"
             echo " * Starting Wi-Fi calibration *"
             echo " ******************************";;
esac

HW_MAC=`calibrator get nvs_mac /pds/wifi/nvs_map.bin | grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}"`
TARGET_FW_DIR=/system/etc/firmware/ti-connectivity
TARGET_NVS_FILE=$TARGET_FW_DIR/wl1271-nvs.bin
TARGET_INI_FILE=/system/etc/wifi/wlan_fem.ini
WL12xx_MODULE=/system/lib/modules/wl12xx_sdio.ko

if [ -e $WL12xx_MODULE ];
then
    echo ""
else
    echo "********************************************************"
    echo "wl12xx_sdio module not found !!"
    echo "********************************************************"
    exit
fi

# Remount system partition as rw
mount -o remount rw /system

# Remove old NVS file
rm /system/etc/firmware/ti-connectivity/wl1271-nvs.bin

# Actual calibration...
# calibrator plt autocalibrate <dev> <module path> <ini file1> <nvs file> <mac addr>
# Leaving mac address field empty for random mac
calibrator plt autocalibrate wlan0 $WL12xx_MODULE $TARGET_INI_FILE $TARGET_NVS_FILE $HW_MAC

echo " ******************************"
echo " * Finished Wi-Fi calibration *"
echo " ******************************"
case "$WIFION" in
  "running") echo " *************************"
             echo " * Turning Wi-Fi back on *"
             echo " *************************"
             svc wifi enable;;
esac
