#!/bin/bash


source ../../scr/settings

# ファイル名を変数に入れる
file_name="wp_x_fudousan.sql"

# Dockerのコンテナにファイル送信
echo $file_name
docker cp ./$file_name $mysql_name:/home/wordpress-auto/sql/

source check.sh

docker exec \
    -it $mysql_name \
        mysql \
            -u $db_user \
            -p$db_password \
            -e "source /home/wordpress-auto/sql/"$file_name

source check.sh