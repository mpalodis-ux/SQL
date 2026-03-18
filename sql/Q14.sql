select t1.genres_name, t1.fest_year, t1.counter                
  from  (select g.genres_name, f.fest_year, count(*) as counter
          from festival f
  	           inner join fest_event e on f.festival_id = e.festival_id
  	           inner join performance p on e.fest_event_id = p.fest_event_id
  	           inner join genres g on (g.artist_id = p.artist_id and p.artist_id is not null and g.artist_id is not null)
  	           					   or (g.band_id = p.band_id and p.band_id is not null and g.band_id is not null)
          group by g.genres_name, f.fest_year 
          having count(*) > 2) as t1
 where exists (select g.genres_name, f.fest_year, count(*) as counter
                 from festival f
  	                  inner join fest_event e on f.festival_id = e.festival_id
  	                  inner join performance p on e.fest_event_id = p.fest_event_id
  	                  inner join genres g on (g.artist_id = p.artist_id and p.artist_id is not null and g.artist_id is not null)
  	           		                      or (g.band_id = p.band_id and p.band_id is not null and g.band_id is not null)
  	            where g.genres_name = t1.genres_name
  	              and f.fest_year = t1.fest_year + 1
             group by g.genres_name, f.fest_year
            having count(*) = t1.counter)
order by 1, 2
        