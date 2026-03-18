select  a.*, (f.fest_year is not null) has_performed
   from artist a
   		inner join genres g on g.artist_id = a.artist_id 
        left join performance p on a.artist_id = p.artist_id
        left join fest_event e on p.fest_event_id = e.fest_event_id 
        left join festival f on e.festival_id = f.festival_id
                            and f.fest_year = date_part('year', now()) - 1
  where g.genres_name = 'rock'
order by a.artist_name;
