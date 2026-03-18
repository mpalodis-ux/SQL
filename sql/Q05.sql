--query5 desc
select a.artist_id, a.artist_name, a.birth_date, count(*) as event_count
  from artist a
       inner join performance p on a.artist_id = p.artist_id
       inner join fest_event fe on fe.fest_event_id = p.fest_event_id 
 where NOW()::date < a.birth_date + interval '30 years'
group by a.artist_id,  a.artist_name, a.birth_date
order by event_count DESC;

--query5 max
/*select t1.artist_id, t1.artist_name, t1.birth_date, t1.performance_count
  from (select a.artist_id, a.artist_name, a.birth_date, count(*) as performance_count
          from artist a
               inner join performance p on a.artist_id = p.artist_id
          where NOW()::date < a.birth_date + interval '30 years'
       group by a.artist_id,  a.artist_name, a.birth_date
       order by performance_count desc ) as t1
   where t1.performance_count = (select count(*) as performance_count
                                   from artist a
                                        inner join performance p on a.artist_id = p.artist_id
                                  where NOW()::date < a.birth_date + interval '30 years'
                                group by a.artist_id,  a.artist_name, a.birth_date
                                order by performance_count desc limit 1);*/

