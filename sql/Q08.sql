select s2.staff_id, s2.staff_name
  from staff s2
where not exists (select s.staff_id
			        from staff s
			  	         inner join event_staff es on es.staff_id = s.staff_id
			     	     inner join fest_event e on e.fest_event_id = es.fest_event_id
			        where e.starting::date = (select starting::date from fest_event limit 1) 
			          and s2.staff_id = s.staff_id) ;
