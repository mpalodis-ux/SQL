 select an.artist_name, count(*) as continent_count
  from (select distinct a.artist_id, l.continent
          from artist a
               left join performance pa on pa.artist_id = a.artist_id
               left join band_members bm on bm.artist_id = a.artist_id
               left join performance pb on pb.band_id = bm.band_id 
               inner join fest_event e on e.fest_event_id = coalesce(pa.fest_event_id, pb.fest_event_id)
               inner join festival f on f.festival_id  = e.festival_id
               inner join location l on l.location_id = f.location_id) as t1
         inner join artist an on an.artist_id = t1.artist_id
group by an.artist_name
having count(*) > 2;

