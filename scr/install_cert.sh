#!/bin/bash

source settings

docker exec \
    -it $wordpress_name \
        apt-get install python-certbot-apache -y

docker exec \
    -it $wordpress_name \
        certbot \
            -d $site_domain \
            --apache \
            --agree-tos \
            -m $certbot_email \
            -n \
            --redirect \
            -w /var/www/html