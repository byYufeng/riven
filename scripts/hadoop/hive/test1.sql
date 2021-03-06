------------------------------------------------------------explode-------------------------------------------------------------------
-- 在hive中使用explode等UDTF函数将字段拆分为多行时，不允许再select其他字段。所以此时应使用Lateral view，将UDTF生成的结果生成一个虚拟表，然后这个虚拟表会和>输入行进行join，来达到连接UDTF外的select字段的目的
-- lateral view explode() t as c： 生成虚拟表t，并映射为字段c
-- >https://my.oschina.net/u/3754001/blog/3028523

-- data: string_list
create table users1(id int, name string, age int, tags string) row format delimited fields terminated by '|';
load data local inpath 'users.txt' into table users1;
select * from users1;
select users1.id, col from users1 lateral view explode(split(tags, ',')) t as col;
--select users.id, t.* from users lateral view explode(split(tags, ',')) t as col;(效果同上)

-- data: array
create table users2(id int, name string, age int, tags array<string>) row format delimited fields terminated by '|' collection items terminated by ',';
load data local inpath 'users.txt' into table users2;
select * from users2;
select users2.id, t.* from users2 lateral view explode(tags) t as col;


-- 列转行
-- 以某一列为key，剩下所有列当做一个字段，每个字段对应的值当做一个字段，把一行的每一列都拆分为一条数据。同样只适于三个字段维度
-- k1=v1,k2=v2,k3=v3,k4=v4 ==> K1=v1,K2=k2,k3..,K3=v2,v3...
-- 分别把B列的值统一成一个字段,再把A列分别硬编码以对应B列的值，然后用union合并起来

(select name, math subject, math score from ft2) union
(select name, art subject, art score from ft2) union 
(select name, sport subject, sport score from ft2) order by name;

/*
+------+------+---------+-------+
| id   | name | subject | score |
+------+------+---------+-------+
|    1 | fgg  | math    |    95 |
|    2 | fgg  | art     |    82 |
|    3 | fgg  | sport   |    86 |
|    4 | gf1  | art     |    85 |
|    5 | gf1  | math    |    90 |
|    6 | gf2  | math    |    61 |
|    7 | gf3  | art     |    90 |
|    8 | gf3  | sport   |    80 |
+------+------+---------+-------+
↑
↓
+------+------+------+-------+
| name | math | art  | sport |
+------+------+------+-------+
| fgg  |   95 |   82 |    86 |
| gf1  |   90 |   85 |     0 |
| gf2  |   61 |    0 |     0 |
| gf3  |    0 |   90 |    80 |
+------+------+------+-------+
*/

-- 行转列
-- 以某一列为key分组聚合，然后把它的每个值当做一列，使用 case when语句构造每一列。仅适用于有三个字段的情况。
-- k1=v1,k2=v2,k3=v3 ==> K1=v1,v21=v31,v22=v32
-- (case original_column1 when new_column1 then original_column2) new_column1, 
-- (case original_column1 when new_column2 then original_column2) new_column2...的形式，然后用max、min等聚合函数取值
select name, 
    max(case subject when 'math' then score else 0 END) math, 
    max(case subject when 'art' then score else 0 END) art, 
    max(case subject when 'sport' then score else 0 END) sport 
from ft1 group by name;
--create table ft2 as (select name, max(case subject when 'math' then score else 0 END) math, max(case subject when 'art' then score else 0 END) art, max(case subject when 'sport' then score else 0 END) sport from ft1 group by name) ;

-- 不存在的值用null而不是0填充 
--create table ft22 (select name, max(case subject when 'math' then score else null END) 'math', max(case subject when 'art' then score else null END) 'art', max(case subject when 'sport' then score else null END) 'sport' from ft1 group by name) ;



-- 行聚合为列
-- ... concat_ws($sep, collect_list(b)) group by a...
-- group_concat 貌似有些时候可以用有些时候不可以？跟版本有关？


-- 列拆分为行
-- explode


-- 分组计算topK
select * from (select name, subject, score, rank() over (partition by subject order by score desc) as rank from ft1) t where rank <= 2;
--先用 rand() over(partition by $key order by value) 计算出每组的排名，再根据排名进行select。
--计算排名有三个函数：rank，dense_rank, row_number()，分别对应排名相同时并列相同且占据名额、并列相同且不占据名额、不并列的三种情况

-- 找出大于平均值的记录
select * from (select *,avg(score) over (partition by subject) as avg_ from ft1) t where score > avg_;
