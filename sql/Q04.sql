select coalesce(a.artist_name, b.band_name) as name, AVG(r.interpretation) as interpretation, AVG(r.overall_impression) as overall_impression
  from review r 
  	   inner join ticket t on r.ticket_id = t.ticket_id
       inner join performance p on p.fest_event_id = t.fest_event_id
       left join artist a on a.artist_id = p.artist_id and p.artist_id is not null
       left join band b on b.band_id = p.band_id and p.band_id is not null
group by coalesce(a.artist_name, b.band_name)
order by 1

