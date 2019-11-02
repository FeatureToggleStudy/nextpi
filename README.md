- Download Raspbian Image from https://downloads.raspberrypi.org/raspbian_lite_latest
- use Etcher to flash img on SD card https://www.balena.io/etcher/
- place a file named ssh onto the boot partition of the SD card to make ssh available
- login via ssh with pi/raspberry
- sudo raspi-config
	- change language, timezone and keyboard
- change standard password with "passwd"
- prepare some things upfront
	- curl -s https://raw.githubusercontent.com/sky321/nextpi/master/prep.sh | /bin/bash
- cd nextpi
- change nextpi.cnf (only var above the line are currently used)
- change standard PI user
	- sudo ./chgusr1.sh
	- login as root
	- /home/pi/nextpi/chgusr2.sh
	- login as new user
- install nextcloud
	- cd nextpi	
	- sudo ./install.sh
- reboot (after reboot the ssh port is changed -> nextpi.cnf)
- optional use nc-restore.sh to restore your data
- optional use nc-datadir.sh to move data to a different dir
- optional use letsencrypt.sh for automated certificates
	- edit fritz.cnf before running the script