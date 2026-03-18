select a.artist_name, count(*) as times_warmup 
  from artist a
       inner join performance p on p.artist_id = a.artist_id
       inner join fest_event e on e.fest_event_id = p.fest_event_id 
       inner join festival f on f.festival_id = e.festival_id
 where p.p_type = 'warm up'
group by a.artist_name
having count(*) > 2
order by times_warmup desc
