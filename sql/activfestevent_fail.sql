update fest_event 
   set active = true
 where fest_event_id in (
select t1.fest_event_id
  from (select fe.fest_event_id, fe.active, sg.capacity, 
               round(sg.capacity * 0.05, 0) as security_need,
               (select count(*) 
                  from event_staff es 
                       inner join staff sf on sf.staff_id = es.staff_id
                       inner join crew_role cr on cr.crew_role_id = sf.staff_crew_role_id
                 where es.fest_event_id = fe.fest_event_id
                   and cr.role_name = 'security') as security_crew,
                round(sg.capacity * 0.02, 0) as assistant_need,
                (select count(*) 
                   from event_staff es 
                        inner join staff sf on sf.staff_id = es.staff_id
                        inner join crew_role cr on cr.crew_role_id = sf.staff_crew_role_id
                  where es.fest_event_id = fe.fest_event_id
                    and cr.role_name <> 'security') as assistant_crew
          from fest_event fe
               inner join stage sg on sg.stage_id = fe.stage_id) as t1
where t1.security_crew < t1.security_need
  and t1.assistant_crew < t1.assistant_need
);