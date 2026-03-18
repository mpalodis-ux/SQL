select v.first_name, v.last_name, coalesce (a.artist_name, b.band_name), r.interpretation
  from review r 
  	   inner join ticket t on r.ticket_id = t.ticket_id
       inner join performance p on p.fest_event_id = t.fest_event_id
       left join artist a on a.artist_id = p.artist_id and p.artist_id is not null
       left join band b on b.band_id = p.band_id and p.band_id is not null
       inner join visitor v on v.visitor_id = t.visitor_id
order by r.interpretation desc limit 5

