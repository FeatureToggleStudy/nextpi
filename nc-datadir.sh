#!/bin/bash

# Data dir configuration script for NextCloudPi
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/13/nextcloudpi-gets-nextcloudpi-config/
#
#####
#
# Moving Datadir is not supported !!!!!!!!!!!!!
#
# https://help.nextcloud.com/t/changing-data-directory/11156
# https://help.nextcloud.com/t/is-there-a-safe-and-reliable-way-to-move-data-directory-out-of-web-root/3642/8
#
#####

PHPVER=7.2
DATADIR=/home/nextcloud/data    
BASEDIR=$( dirname "$DATADIR" )

  ## CHECKS
  SRCDIR=$( cd /var/www/nextcloud; sudo -u www-data php occ config:system:get datadirectory ) || {
    echo -e "Error reading data directory. Is NextCloud running and configured?"; 
    exit;
  }
  [ -d "$SRCDIR" ] || { echo -e "data directory $SRCDIR not found"; exit; }

  [[ "$SRCDIR" == "$DATADIR" ]] && { echo -e "INFO: data already there"; exit; }

  [ -d "$BASEDIR" ] || { echo "$BASEDIR does not exist"; exit; }

  # If the user chooses the root of the mountpoint, force a folder
  #mountpoint -q "$DATADIR" && {
  #  BASEDIR="$DATADIR"
  #}

  #grep -q -e ext -e btrfs <( stat -fc%T "$BASEDIR" ) || {
  #  echo -e "Only ext/btrfs filesystems can hold the data directory"
  #  return 1
  #}

  #sudo -u www-data test -x "$BASEDIR" || {
  #  echo -e "ERROR: the user www-data does not have access permissions over $BASEDIR"
  #  return 1
  #}

  #[[ "$DATADIR" != "/var/www/nextcloud/data" ]] && \
  #[[ $( stat -fc%d / ) == $( stat -fc%d "$BASEDIR" ) ]] && {
  #  echo "Refusing to move to the SD card. Abort"
  #  return 1
  #}

  cd /var/www/nextcloud
  sudo -u www-data php occ maintenance:mode --on  
  
  # backup possibly existing datadir
  [ -d $DATADIR ] && {
    BKP="${DATADIR}-$( date "+%m-%d-%y" )" 
    echo "INFO: $DATADIR is not empty. Creating backup $BKP"
    mv "$DATADIR" "$BKP"
  }

  ## COPY
  echo "moving data dir from $SRCDIR to $DATADIR..."

  mkdir -p $BASEDIR 
  chown www-data:www-data $BASEDIR 
  rsync -avP "$SRCDIR" "$BASEDIR" || exit
#  cp -r "$SRCDIR" "$BASEDIR" || exit
  chown www-data:www-data "$DATADIR"
 
  # tmp upload dir
  mkdir -p "$DATADIR/tmp" 
  chown www-data:www-data "$DATADIR/tmp"
  sudo -u www-data php occ config:system:set tempdirectory --value "$DATADIR/tmp"
  sed -i "s|^;\?upload_tmp_dir =.*$|uploadtmp_dir = $DATADIR/tmp|" /etc/php/${PHPVER}/cli/php.ini
  sed -i "s|^;\?upload_tmp_dir =.*$|upload_tmp_dir = $DATADIR/tmp|" /etc/php/${PHPVER}/fpm/php.ini
  sed -i "s|^;\?sys_temp_dir =.*$|sys_temp_dir = $DATADIR/tmp|"     /etc/php/${PHPVER}/fpm/php.ini

  # opcache dir
  sed -i "s|^opcache.file_cache=.*|opcache.file_cache=$DATADIR/.opcache|" /etc/php/${PHPVER}/mods-available/opcache.ini

  # update fail2ban logpath
  sed -i "s|logpath  =.*nextcloud.log|logpath  = $DATADIR/nextcloud.log|" /etc/fail2ban/jail.local

#  sudo -u www-data php occ maintenance:mode --off

  # datadir & tmp
  sudo -u www-data php occ config:system:set datadirectory --value="$DATADIR"
  sudo -u www-data php occ config:system:set logfile --value="$DATADIR/nextcloud.log"
  sudo -u www-data php occ maintenance:mode --off

  rm -r $SRCDIR
#  echo "Edit the database: In oc_storages change the path on the local::/old-data-dir/ entry"
  echo "check/run permission.sh and reboot the server"

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

