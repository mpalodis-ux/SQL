select an.artist_name, sum(performance_count) 
  from (select pa.artist_id, count(*) as performance_count
          from performance pa 
         where pa.artist_id is not null
        group by pa.artist_id
        union all
        select bm.artist_id, count(*) as performance_count
          from performance pb 
               inner join band_members bm on bm.band_id = pb.band_id 
         where pb.band_id is not null
        group by bm.artist_id
        order by performance_count desc) t1
        inner join artist an on an.artist_id  = t1.artist_id
 where t1.performance_count + 5 < (select count(*) as performance_count
                                     from performance pa 
                                    where pa.artist_id is not null
                                   group by pa.artist_id
                                   union all
                                  select count(*) as performance_count
                                    from performance pb 
        			                     inner join band_members bm on bm.band_id = pb.band_id 
                                   where pb.band_id is not null
                                  group by bm.artist_id
                                  order by performance_count desc limit 1)
 group by an.artist_name
 order by 2 desc;
