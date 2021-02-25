#!/bin/bash



source ../../scr/settings

# ファイル名を変数に入れる
file_name="wp_x_nen.sql"

# Dockerのコンテナにファイル送信
echo $file_name
docker cp ./$file_name $mysql_name:/home/wordpress-auto/sql/


echo
echo -----------------------------------------
echo check.sh $file_name before
echo -----------------------------------------
source check.sh

echo
echo -----------------------------------------
echo SQL実行
echo -----------------------------------------

# SQLを実行する
docker exec \
    -it $mysql_name mysql \
    -u $db_user \
    -p$db_password \
    -e "source /home/wordpress-auto/sql/"$file_name

echo
echo -----------------------------------------
echo check.sh $file_name after
echo -----------------------------------------
source check.sh