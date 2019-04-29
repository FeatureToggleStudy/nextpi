- Download Raspbian Image from https://downloads.raspberrypi.org/raspbian_lite_latest
- use Etcher to flash img on SD card https://www.balena.io/etcher/
- boot with display and keyboard
- login with pi/raspberry
- change standard password with "passwd"
- start raspi-config
	- change language
	- make ssh available (generate new key)
- login with ssh
- install git with "sudo apt-get install git"
	- git clone https://github.com/sky321/nextpi.git
	- cd nextpi
	- chmod +x *.sh
- optional change standard PI user with chgusr.sh (!!! check inline comments !!!)
- change nextpi.cnf (only var above the line are currently used)
- install nextcloud
	- cd nextpi	
	- sudo ./install.sh
- login to nextcloud and change your password
- reboot (after reboot the ssh port is changed -> see syscfg.sh)
- optional use nc-restore.sh to restore your data
- optional use nc-datadir.sh to move data to a different dir
- optional use letsencrypt.sh for automated certificates
	- edit fritz.cnf before running the script