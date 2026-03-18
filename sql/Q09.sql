select vn.last_name, vn.first_name, t1.fest_year, t1.watched_counter 
  from (select v.visitor_id, f.fest_year, count(*) as watched_counter
   	      from visitor v 
               inner join ticket t on t.visitor_id = v.visitor_id
               inner join fest_event fe on fe.fest_event_id = t.fest_event_id
               inner join festival f on f.festival_id = fe.festival_id
      group by v.visitor_id, f.fest_year
      having count(*) > 3) as t1
       inner join (select v.visitor_id, f.fest_year, count(*) as watched_counter
                     from visitor v 
                          inner join ticket t on t.visitor_id = v.visitor_id
                          inner join fest_event fe on fe.fest_event_id = t.fest_event_id
                          inner join festival f on f.festival_id = fe.festival_id
                 group by v.visitor_id, f.fest_year
                 having count(*) > 3) t2 on t1.visitor_id <> t2.visitor_id and t1.fest_year = t2.fest_year and t1.watched_counter = t2.watched_counter
       inner join visitor vn on vn.visitor_id = t1.visitor_id