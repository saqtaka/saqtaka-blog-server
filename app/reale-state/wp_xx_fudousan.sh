#!/bin/bash

yum install file -y

source ../../scr/settings

file_name="wp_xx_fudousan.sql"

source check.sh


docker exec $mysql_name mkdir /home/wordpress-auto
docker exec $mysql_name mkdir /home/wordpress-auto/sql

echo $file_name
docker cp ./$file_name $mysql_name:/home/wordpress-auto/sql/

docker exec \
    -it $mysql_name \
        mysql \
            -u $db_user \
            -p$db_password \
            -e "source /home/wordpress-auto/sql/"$file_name


rm .cache -r -f
mkdir .cache
mkdir .cache/csv
mkdir .cache/csv-utf-8
cd .cache

curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20151_20154.zip
curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20161_20164.zip
curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20171_20174.zip
curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20181_20184.zip
curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20191_20194.zip
curl -O https://makeshipcom-chika-data.s3-ap-northeast-1.amazonaws.com/All_20201_20202.zip

yum install unzip -y

unzip -d ./csv All_20151_20154.zip
unzip -d ./csv All_20161_20164.zip
unzip -d ./csv All_20171_20174.zip
unzip -d ./csv All_20181_20184.zip
unzip -d ./csv All_20191_20194.zip
unzip -d ./csv All_20201_20202.zip

cd ./csv

find . -name '*.csv' | while read file
do
    echo $file | sed -e "s/.\///"

    # csvの先頭行を削除
    sed -i '1,1d' "`echo $file | sed -e "s/.\///"`"

    # 文字コード & 改行コードを変更
    # UTF-8 & LF
    file -i "`echo $file | sed -e "s/.\///"`"
    iconv -c -f SHIFT-JIS -t UTF-8 "`echo $file | sed -e "s/.\///"`" | tr -d '\r' > ../csv-utf-8/"`echo $file | sed -e "s/.\///"`"

done


cd ../csv-utf-8

docker exec -it $mysql_name rm /home/wordpress-auto/app -r -f
docker exec -it $mysql_name mkdir /home/wordpress-auto/app
docker exec -it $mysql_name mkdir /home/wordpress-auto/app/fudousan
docker exec -it $mysql_name mkdir /home/wordpress-auto/app/fudousan/csv
docker cp . $mysql_name:/home/wordpress-auto/app/fudousan/csv

find . -name '*.csv' | while read file
do
    # ファイル名を出力
    echo $file | sed -e "s/.\///"

    docker exec \
        $mysql_name \
            mysql \
                -u $db_user \
                -p$db_password \
                -e "LOAD DATA LOCAL INFILE \"/home/wordpress-auto/app/fudousan/csv/`echo $file | sed -e "s/.\///"`\" INTO TABLE wordpress.wp_xx_fudousan FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"';"
done

source check.sh

cd ../../
