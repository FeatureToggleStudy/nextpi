#!/bin/sh

echo "delete port 80 mapping ...."

IPS=$( grep IPS /root/.fritz.cnf | sed 's|IPS=||' )

FRITZUSER=$( grep FRITZUSER /root/.fritz.cnf | sed 's|FRITZUSER=||' )
FRITZPW=$( grep FRITZPW /root/.fritz.cnf | sed 's|FRITZPW=||' )

location="/upnp/control/wanpppconn1"
uri="urn:dslforum-org:service:WANPPPConnection:1"
action='DeletePortMapping' 
SoapParamString="<NewRemoteHost>0.0.0.0</NewRemoteHost>
<NewExternalPort>80</NewExternalPort>
<NewProtocol>TCP</NewProtocol>"

for IP in ${IPS}; do
        curl -k -m 5 --anyauth -u "$FRITZUSER:$FRITZPW" https://$IP:49443$location -H 'Content-Type: text/xml; charset="utf-8"' -H "SoapAction:$uri#$action" -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'>$SoapParamString</u:$action></s:Body></s:Envelope>" -s
done