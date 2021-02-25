#!/bin/bash

source ../../scr/settings

docker exec \
    -it $mysql_name \
        mysql \
            -u $db_user \
            -p$db_password \
            -e "select table_name, table_rows from information_schema.TABLES where table_schema = 'wordpress';"
