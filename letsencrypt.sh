#!/bin/bash

# Let's encrypt certbot installation on Raspbian 
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# More at https://ownyourbits.com/2017/03/17/lets-encrypt-installer-for-apache/
##
# You can get the updated packages for certbot by adding the stable-updates archive
# for your distribution to your /etc/apt/sources.list:
#
#deb http://deb.debian.org/debian stretch-updates main
#deb-src http://deb.debian.org/debian stretch-updates main
#

DOMAIN_=mycloud.ownyourbits.com  # replace with your own domain
EMAIL_=mycloud@ownyourbits.com   # replace with your own email
NOTIFYUSER_=ncp                  # replace with your own nextcloud user

NCDIR=/var/www/nextcloud
OCC="$NCDIR/occ"
VHOSTCFG=/etc/apache2/sites-available/nextcloud.conf
#VHOSTCFG2=/etc/apache2/sites-available/ncp.conf
DESCRIPTION="Automatic signed SSL certificates"

INFOTITLE="Warning"
INFO="Internet access is required for this configuration to complete
Both ports 80 and 443 need to be accessible from the internet
 
Your certificate will be automatically renewed every month"

#is_active()
#{
#  [[ $( find /etc/letsencrypt/live/ -maxdepth 0 -empty | wc -l ) == 0 ]]
#}

  cd /etc || return 1
  apt-get update
  apt-get install --no-install-recommends -y letsencrypt
  mkdir -p /etc/letsencrypt/live

# tested with certbot 0.10.2

  DOMAIN_LOWERCASE="${DOMAIN_,,}"

  
  # Configure Apache
  grep -q ServerName $VHOSTCFG && \
    sed -i "s|ServerName .*|ServerName $DOMAIN_|" $VHOSTCFG || \
    sed -i "/DocumentRoot/aServerName $DOMAIN_" $VHOSTCFG 

  # Do it
  letsencrypt certonly -n --no-self-upgrade --webroot -w $NCDIR --hsts --agree-tos -m $EMAIL_ -d $DOMAIN_ && {

    # Set up auto-renewal
    cat > /etc/cron.daily/letsencrypt-ncp <<EOF
#!/bin/bash

# renew and notify
/usr/bin/certbot renew --quiet --renew-hook '
  sudo -u www-data php $OCC notification:generate \
                            $NOTIFYUSER_ "SSL renewal" \
                            -l "Your SSL certificate(s) \$RENEWED_DOMAINS has been renewed for another 90 days"
  '

# notify if fails
[[ \$? -ne 0 ]] && sudo -u www-data php $OCC notification:generate \
                                             $NOTIFYUSER_ "SSL renewal error" \
                                             -l "SSL certificate renewal failed. See /var/log/letsencrypt/letsencrypt.log"

# cleanup
rm -rf $NCDIR/.well-known
EOF
    chmod +x /etc/cron.weekly/letsencrypt-ncp

    # Configure Apache
    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $VHOSTCFG
    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $VHOSTCFG

#    sed -i "s|SSLCertificateFile.*|SSLCertificateFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/fullchain.pem|" $VHOSTCFG2
#    sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN_LOWERCASE/privkey.pem|" $VHOSTCFG2

    # Configure Nextcloud
    sudo -u www-data php $OCC config:system:set trusted_domains 0 --value=$DOMAIN_
    sudo -u www-data php $OCC config:system:set overwrite.cli.url --value=https://"$DOMAIN_"/

    # delayed in bg so it does not kill the connection, and we get AJAX response
    bash -c "sleep 2 && service apache2 reload" &>/dev/null &
    rm -rf $NCDIR/.well-known
    
    # Update configuration
#    [[ "$DOCKERBUILD" == 1 ]] && update-rc.d letsencrypt enable

    echo "Letsencrypt is finished successful"
    return 0
  }
  rm -rf $NCDIR/.well-known
#  return 1
  echo "something went wrong with the cert"


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

