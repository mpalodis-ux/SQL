select t3.* from (
select t2.fest_year, round(AVG(t2.average_counter), 2) as average_counted
  from (select s.staff_id, f.fest_year, 
               case when s.experience_level = 'intern' then 0
                    when s.experience_level = 'beginner' then 1
                    when s.experience_level = 'intermediate' then 2
                    when s.experience_level = 'experienced' then 3
                    when s.experience_level = 'expert' then 4
               end as average_counter
          from staff s
               inner join event_staff es on s.staff_id = es.staff_id
               inner join fest_event e on es.fest_event_id = e.fest_event_id
               inner join festival f on e.festival_id = f.festival_id) as t2
      group by t2.fest_year 
      order by average_counted) as t3
 where t3.average_counted = (select min(t3.average_counted)
                               from (select t2.fest_year, round(AVG(t2.average_counter), 2) as average_counted
                                       from (select s.staff_id, f.fest_year, 
                                                    case when s.experience_level = 'intern' then 0
                                                         when s.experience_level = 'beginner' then 1
                                                         when s.experience_level = 'intermediate' then 2
                                                         when s.experience_level = 'experienced' then 3
                                                         when s.experience_level = 'expert' then 4
                                                    end as average_counter
                                               from staff s
                                                    inner join event_staff es on s.staff_id = es.staff_id
                                                    inner join fest_event e on es.fest_event_id = e.fest_event_id
                                                    inner join festival f on e.festival_id = f.festival_id) as t2
                                           group by t2.fest_year 
                                           order by average_counted) as t3)
