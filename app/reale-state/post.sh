#!/bin/bash


source ../../scr/settings

# jq install
yum -y install jq

# 設定ファイル作成
docker exec -ti $mysql_name \
    sh -c "mkdir /home/wordpress-auto"

docker exec -ti $mysql_name \
    sh -c "echo '[client]' > /home/wordpress-auto/db.cnf"

docker exec -ti $mysql_name \
    sh -c "echo 'password=$db_password' >> /home/wordpress-auto/db.cnf"

# 市区町村の一覧をテキストファイルにエクスポート
docker exec -it $mysql_name \
    mysql \
        --defaults-extra-file=/home/wordpress-auto/db.cnf \
        -u $db_user \
        -B \
        -N \
        -e "select CONCAT(todoufukenmei, shikutyousonmei) from wordpress.wp_x_shikutyouson" > .cache/wp_x_shikutyouson.csv

docker exec $wordpress_name \
    sh -c "wp scaffold post-type reale-state --theme='$wp_theme' --allow-root"


docker exec $wordpress_name \
    sh -c "echo '' >> /var/www/html/wp-content/themes/$wp_theme/functions.php"

docker exec $wordpress_name \
    sh -c "echo \"require get_template_directory() . '/post-types/reale-state.php';\" >> /var/www/html/wp-content/themes/$wp_theme/functions.php"

docker exec $wordpress_name \
    sh -c "echo '' >> /var/www/html/wp-content/themes/$wp_theme/functions.php"

while read line
do
    echo $line

    # crを削除
    tdfk_skts="`echo $line | tr -d "\r"`"
    echo $tdfk_skts

    docker exec $mysql_name \
        sh -c "mysql \
            --defaults-extra-file=/home/wordpress-auto/db.cnf \
            -u $db_user \
            -B \
            -N \
            -e \"select \
                  T002.tdfk_skts, \
                  T002.syurui, \
                  T001.nen, \
                  T002.tsubotanka, \
                  T002.kensuu \
                from \
                  wordpress.wp_x_nen as T001 \
                  left join \
                  wordpress.wp_x_fudousan_display as T002 \
                  on \
                  T001.nen = T002.nen \
                where \
                  (T002.syurui = '宅地(土地)') \
                  and \
                  (T002.tdfk_skts = '$tdfk_skts') \
                order by \
                  T002.syurui, \
                  T001.nen\"" > .cache/$line.csv

    # json=""`jq -s -R 'split("\n")|map(split("\t"))|map({"tdfk_skts": .[0], "syurui": .[1], "nen": .[2], "tsubotanka": .[3], "kensuu": .[4]})' .cache/''$'\344\270\211\351\207\215\347\234\214\343\201\204\343\201\252\343\201\271\345\270\202''.txt' |jq 'del(.[][] | nulls)' | head -n -2 | sed -e 1d -e 's/},/}/g' | jq . -c`
    json="`jq -s -R 'split("\n")|map(split("\t"))|map({"tdfk_skts": .[0], "syurui": .[1], "nen": .[2], "tsubotanka": .[3], "kensuu": .[4]})' .cache/$line.csv | jq 'del(.[][] | nulls)' | head -n -2 | sed -e 1d -e 's/},/}/g' | jq . -c | tr -d "\n"`"
    echo $json

    docker exec $wordpress_name \
        sh -c "wp post create \
            --allow-root \
            --path='/var/www/html/' \
            --post_content=$json \
            --post_date='2019-6-16 00:00:00' \
            --post_modified='2019-6-16 00:00:00' \
            --post_status='publish' \
            --post_title=${line} \
            --post_type='reale-state'"

done < ./.cache/wp_x_shikutyouson.csv
