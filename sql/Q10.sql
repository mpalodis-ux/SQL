select  t1.name1, t1.name2, f.fest_year, sum(ta.performance_count)
  from (-- το παρακατω δημιουργει ολα τα ζευγη ειδων μουσικης μοναδικα
        select distinct gd1.genres_name as name1, gd2.genres_name as name2
          from genres gd1
               cross join genres gd2
         where gd1.genres_name < gd2.genres_name) t1
        inner join genres g1 on g1.genres_name = t1.name1
        inner join genres g2 on g2.genres_name = t1.name2 and g2.artist_id = g1.artist_id
        left join lateral (select pa.artist_id, pa.fest_event_id, count(*) as performance_count
                            from performance pa 
                           where pa.artist_id = g1.artist_id and pa.artist_id is not null
                          group by pa.artist_id, pa.fest_event_id
                          union all
                          select bm.artist_id, pb.fest_event_id, count(*) as performance_count
        	                from performance pb 
        			             inner join band_members bm on bm.band_id = pb.band_id 
                           where bm.artist_id = g1.artist_id
                          group by bm.artist_id, pb.fest_event_id) as ta on ta.artist_id = g1.artist_id
        inner join fest_event e on e.fest_event_id = ta.fest_event_id 
        inner join festival f on f.festival_id = e.festival_id
group by   t1.name1, t1.name2, f.fest_year
order by 4 desc limit 3
