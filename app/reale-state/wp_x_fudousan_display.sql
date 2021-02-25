drop table if exists wordpress.wp_x_fudousan_display;

create table if not exists wordpress.wp_x_fudousan_display
(
    tdfk_skts nvarchar(200) not null,
    todoufukenmei nvarchar(200) not null,
    shikutyousonmei nvarchar(200) not null,
    syurui nvarchar(200) not null,
    nen int not null,
    tsubotanka int null,
    kensuu int null,
    PRIMARY KEY(tdfk_skts, syurui, nen)
);

delete from wordpress.wp_x_fudousan_display;

select
    *
from
wordpress.wp_x_fudousan_display
limit 200;

insert into wordpress.wp_x_fudousan_display
(
    tdfk_skts,
    todoufukenmei,
    shikutyousonmei,
    syurui,
    nen,
    tsubotanka,
    kensuu
)
select
    concat(wp_x_fudousan.todoufukenmei, wp_x_fudousan.shikutyousonmei),
    wp_x_fudousan.todoufukenmei,
    wp_x_fudousan.shikutyousonmei,
    wp_x_fudousan.syurui,
    wp_x_kikan.nen,
    round(avg(wp_x_fudousan.tsubotanka), 0),
    count(wp_x_fudousan.no)
from
    wordpress.wp_x_kikan
    right join		
    wordpress.wp_x_fudousan
    on
    wp_x_kikan.torihikijiten = wp_x_fudousan.torihikijiten		
where
    (wp_x_fudousan.syurui = '宅地(土地)')
group by
    wp_x_fudousan.todoufukenmei,
    wp_x_fudousan.shikutyousonmei,
    wp_x_fudousan.syurui,
    wp_x_kikan.nen
order by
    wp_x_fudousan.todoufukenmei,
    wp_x_fudousan.shikutyousonmei,
    wp_x_fudousan.syurui,
    wp_x_kikan.nen;

select
    *
from
    wordpress.wp_x_fudousan_display
limit 200;
