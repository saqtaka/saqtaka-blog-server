#!/bin/bash

source settings

docker exec \
    -it $wordpress_name \
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

docker exec \
    -it $wordpress_name \
        chmod +x wp-cli.phar

docker exec \
    -it $wordpress_name \
        mv wp-cli.phar /usr/local/bin/wp

docker exec \
    -it $wordpress_name \
        wp core install \
            --allow-root \
            --url=$protocol://$site_domain \
            --title=$site_title \
            --admin_user=$wp_user \
            --admin_password=$wp_password \
            --admin_email=$wp_email

docker exec \
    -it $wordpress_name \
        wp rewrite structure '/p=%post_id%' --allow-root
