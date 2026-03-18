select f.fest_year, starting::date as fest_date,
       sum(floor(s.capacity / 20 - 0.0001) + 1) as technical_security_staff_required, 
       sum(floor(s.capacity / 50 - 0.0001) + 1) as assistance_staff_required
  from festival f
 	   inner join fest_event e on e.festival_id = f.festival_id 
	   inner join stage s on s.stage_id = e.stage_id 
 where fest_year = '2024'
 group by f.fest_year, starting::date
