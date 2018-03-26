#!/bin/bash
cd /usr/local/bin/letsencrypt
sudo ./letsencrypt-auto certonly --email admin@threedegreesapp.com --debug --standalone -d api.threedegreesapp.com
cd ~
. ./load-env.sh
sudo openssl pkcs12 -export -out threedegrees-keystore.p12 -inkey /etc/letsencrypt/live/api.threedegreesapp.com/privkey.pem -in /etc/letsencrypt/live/api.threedegreesapp.com/fullchain.pem -password env:SSL_PASSWORD
sudo chown ec2-user:ec2-user threedegrees-keystore.p12
keytool -importkeystore -destkeystore threedegrees-keystore.jks -srcstoretype PKCS12 -srckeystore threedegrees-keystore.p12 -srcstorepass $SSL_PASSWORD -deststorepass $SSL_PASSWORD -noprompt
kill `ps aux | grep svc-threedegrees | grep -v grep | awk -F ' ' '{print $2}'`
nohup svc-threedegrees-0.0.0-SNAPSHOT/bin/svc-threedegrees -Dconfig.resource=stage.conf -Dhttp.port=disabled -Dhttps.port=9443 -Dhttps.keyStore=threedegrees-keystore.jks -Dhttps.keyStorePassword=$SSL_PASSWORD -Djdk.tls.ephemeralDHKeySize=2048 -Djdk.tls.rejectClientInitiatedRenegotiation=true &
