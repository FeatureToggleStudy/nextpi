#!/bin/bash

# Unattended upgrades installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at: ownyourbits.com 
#

ACTIVE_=yes
AUTOREBOOT_=yes
DESCRIPTION="Automatic installation of security updates. Keep your cloud safe"

install()
{
  apt-get update
  apt install -y --no-install-recommends unattended-upgrades 
  rm /etc/apt/apt.conf.d/20auto-upgrades
}

configure() 
{ 
  [[ $ACTIVE_     == "yes" ]] && local AUTOUPGRADE=1   || local AUTOUPGRADE=0
  [[ $AUTOREBOOT_ == "yes" ]] && local AUTOREBOOT=true || local AUTOREBOOT=false

  local RELEASE=$( grep RELEASE /root/.nextpi.cnf | sed 's|RELEASE=||' )

  # Raspbian case
  grep -q Raspbian /etc/issue && {

    # It seems like the label Raspbian-Security does not work for Raspbian
    # See https://www.raspberrypi.org/forums/viewtopic.php?t=82863&p=585739
    cat > /etc/apt/apt.conf.d/20ncp-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "$AUTOUPGRADE";
APT::Periodic::MaxAge "14"; 
APT::Periodic::AutocleanInterval "7";
Unattended-Upgrade::Automatic-Reboot "$AUTOREBOOT";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
Unattended-Upgrade::Origins-Pattern {
o=Raspbian,n="$RELEASE",l=Raspbian;
}
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
};
EOF

  # Armbian case # TODO security only?
  } || {
    cat > /etc/apt/apt.conf.d/20ncp-upgrades <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "$AUTOUPGRADE";
APT::Periodic::MaxAge "14"; 
APT::Periodic::AutocleanInterval "7";
Unattended-Upgrade::Automatic-Reboot "$AUTOREBOOT";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
Unattended-Upgrade::Origins-Pattern {
o=Debian,n="$RELEASE",l=Debian;
}
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
};
EOF
  }
  echo "Unattended upgrades active: $ACTIVE_ (autoreboot $AUTOREBOOT_)"
}

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

