---
layout: post
title: Oracle时间处理
tags: db oracle
---
Oracle时间处理的一些记录

----


*  查询当前时间

        SELECT SYSDATE FROM DUAL;

*  查询1天前和1天后的当前时间：

        SELECT SYSDATE-1,SYSDATE+1 FROM DUAL;

*  查询上月的第一天：

        SELECT TO_CHAR(ADD_MONTHS(LAST_DAY(SYSDATE)+1,-2),'YYYY-MM-DD')  FROM DUAL;


*  查询两个时间相差的月数：

        SELECT MONTHS_BETWEEN(SYSDATE+30,SYSDATE) FROM DUAL;--（如果当月为30天，返回1，为31天返回0.967741935483871）


*  查询一年中所有的星期五：

        SELECT TO_CHAR(t.d, 'yyyy-mm-dd'), to_char(t.d, 'day') from (select trunc(sysdate, 'YY') + rownum - 1 as d from dba_objects where rownum <= TO_CHAR(ADD_MONTHS(trunc(sysdate, 'YY'), 12) - 1, 'DDD')) t where to_char(t.d, 'd') = 6;
        SELECT TO_CHAR(t.d, 'yyyy-mm-dd'), to_char(t.d, 'day') from (select trunc(sysdate, 'YY') + rownum - 1 as d from dba_objects where rownum <= TO_CHAR(LAST_DAY(ADD_MONTHS(trunc(sysdate, 'YY'),11)),'DDD')) t where to_char(t.d, 'd') = 6;


*  查询一年四个季度各有多少天：

        select (case when jijie = 1 then  '第一季' when jijie = 2 then '第二季' when jijie = 3 then  '第三季'  else '第四季' end) 季度 ,tianshu 天数 from (select to_char(d, 'q') jijie, sum(a) tianshu from (select 1 a, trunc(sysdate, 'YY') + rownum - 1 as d from dba_objects where rownum <= TO_CHAR(LAST_DAY(ADD_MONTHS(trunc(sysdate, 'YY'), 11)), 'DDD'))  group by to_char(d, 'q'))

*  查询当年有多少个工作日(周一到周五)：

        select count(d)  from(select trunc(sysdate, 'YY') + rownum - 1 as d  from dba_objects where rownum <= TO_CHAR(ADD_MONTHS(trunc(sysdate, 'YY'), 12) - 1, 'DDD')) where to_char(d,'d')<>1 and to_char(d,'d')<>7
