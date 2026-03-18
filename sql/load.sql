DROP TRIGGER if exists no_festival_updates_or_deletes ON festival;
DROP TRIGGER if exists no_fest_events_deletes ON fest_event;

delete from ticket_resale_queue;
delete from ticket_resale_interest;
delete from review;
delete from ticket;
delete from visitor;
delete from band_members;
delete from performance_staff;
delete from event_staff;
delete from performance;
delete from genres;
delete from band;
delete from artist;
delete from staff;
delete from fest_event;
delete from stage_crew;
delete from stage_equipment;
delete from stage;
delete from festival;
delete from location;
delete from equipments;
delete from crew_role;

CREATE or replace TRIGGER no_fest_events_deletes
BEFORE delete ON fest_event
FOR EACH ROW
EXECUTE PROCEDURE deny_event_delete();
CREATE or replace TRIGGER no_festival_updates_or_deletes
BEFORE update or delete ON festival
FOR EACH ROW
EXECUTE PROCEDURE deny_festival_upd_del();


insert into equipments (equip_type) values ('speakers');
insert into equipments (equip_type) values ('lights');
insert into equipments (equip_type) values ('microphones');
insert into equipments (equip_type) values ('consoles');
insert into equipments (equip_type) values ('special effects');

insert into crew_role (role_name) values ('technician');
insert into crew_role (role_name) values ('security');
insert into crew_role (role_name) values ('cleaner');
insert into crew_role (role_name) values ('assistant');

drop sequence if exists serial;
create sequence serial start 1;
-- generate 20 random rows for the 'location' table
insert into location (address, latitude, longitude, city, country, continent)
select t1.address, t1.latitude, t1.longitude, t1.city, t1.country, 
       case when t1.num = 1 then 'america'
            when t1.num = 2 then 'asia'
            when t1.num = 3 then 'africa'
            when t1.num = 4 then 'europe'
            else 'australia'
       end as continent
  from (select 'street ' || (random() * 1000)::int as address, 
               (random() * 180 - 90)::decimal(9,6) as latitude, 
               (random() * 360 - 180)::decimal(9,6) as longitude,  
               'city ' || (random() * 100)::int as city, 
               'country ' || (random() * 50)::int as country,
               floor(random() * 5)::int as num
  from generate_series(1, 20)) as t1
limit 15;

drop sequence if exists serial;
create sequence serial start 1;
-- generate 8 random rows for the 'festival' table
insert into festival (fest_name, location_id, fest_year, start_date, end_date)
select t2.fest_name, t2.location_id, t2.fest_year, t2.start_date, t2.start_date + (t2.duration * interval '1 days') end_date
  from (select 'festival ' || t1.fest_year::text as fest_name, t1.location_id, t1.fest_year,
               make_date(t1.fest_year, case when t1.fmonth < 1 then 1 when t1.fmonth > 12 then 12 else fmonth end, 
                         case when t1.fday < 1 then 1 when t1.fday > 28 then 28 else fday end) start_date,
               floor(random() * 12 /* to insert illegal rows replace with 16 */) as duration
          from (select l.location_id, 2019 + nextval('serial')::int fest_year,
                       floor(random() * 12)::int as fmonth, floor(random() * 21)::int as fday
                  from generate_series(1, 5)
                       cross join location l) as t1) as t2 
limit 10;

-- generate 30 random rows for the 'stage' table
insert into stage (stage_name, stage_description, capacity)
select 'stage name' || generate_series, 'stage description for name' || generate_series, 
       floor(random() * 20)::int * 10 as capacity
  from generate_series(1, 30);
insert into stage (stage_name, stage_description, capacity)
select 'stage name' || generate_series, 'stage description for name' || generate_series, 
       50 as capacity
  from generate_series(1, 30) limit 1;

insert into stage_equipment (stage_id, stage_equip_id, equip_quantity)
select s.stage_id, e.equip_id, floor(random() * 5)::int as quantity
  from stage s
       cross join equipments e;
delete from stage_equipment where equip_quantity = 0;

insert into stage_crew (stage_id, stage_crew_role_id, crew_quantity)
select s.stage_id, c.crew_role_id, round(s.capacity * 0.05, 0) as quantity
  from stage s
       inner join crew_role c on c.role_name = 'security';
insert into stage_crew (stage_id, stage_crew_role_id, crew_quantity)
select s.stage_id, c.crew_role_id, round(s.capacity * 0.01, 0) as quantity
  from stage s
       inner join crew_role c on c.role_name = 'technician';
insert into stage_crew (stage_id, stage_crew_role_id, crew_quantity)
select s.stage_id, c.crew_role_id, round(s.capacity * 0.01, 0) as quantity
  from stage s
       inner join crew_role c on c.role_name = 'cleaner';

-- generate 80+ random rows for the 'fest_event' table
drop table if exists temp_fe;
create table temp_fe (festival_id uuid, stage_id uuid, starting timestamp, ending timestamp);
with recursive timeslots as (
  select f.festival_id, s.stage_id, f.start_date + interval '12 hours' as starting, f.start_date + interval '15 hours' as ending,  f.end_date
    from festival f
         cross join stage s
  union all
  select t.festival_id, t.stage_id, t.ending + interval '1 hours' as starting, t.ending + interval '5 hours' as ending,  t.end_date
    from timeslots t
   where t.ending + interval '5 hours' <= t.end_date
)
insert into temp_fe (festival_id, stage_id, starting, ending)
select festival_id, stage_id, starting, ending
  from timeslots
order by 1, 2, 3;
delete from temp_fe where date_part('hours', temp_fe.starting) between 1 and 17;
insert into fest_event (festival_id, stage_id, starting, ending)
select festival_id, stage_id, starting, ending 
  from temp_fe
order by random()
limit 200;

drop sequence if exists serial;
create sequence serial start 1;
--generate random rows for the 'staff' table
insert into staff (staff_name, birth_date, staff_crew_role_id, experience_level)
select t3.staff_name, t3.birth_date, 
       t3.crew_role_id,
	   case when coalesce(tempor2, 0) < 2 then'intern'
	        when coalesce(tempor2, 0) between 2 and 4 then 'beginner'
	        when coalesce(tempor2, 0) between 4 and 6 then 'intermediate'
	        when coalesce(tempor2, 0) between 6 and 10 then 'experienced'
	        when coalesce(tempor2, 0) > 10 then 'expert'
       end as experience 
  from (select 'name ' ||  nextval('serial')::int as staff_name, c.crew_role_id,
               (now() - (random() * interval '60 years'))::date as birth_date,
               random()*10::int as tempor, random()*10::int as tempor2
          from generate_series(1, 100)
               cross join crew_role c
         order by 1) as t3;

-- generate 1800 random rows for the 'event_staff' table
insert into event_staff (fest_event_id, staff_id)
select fe.fest_event_id, s.staff_id
  from fest_event fe
       inner join stage st on fe.stage_id = st.stage_id
       cross join lateral (select s1.staff_id
                             from staff s1
                                  inner join crew_role cr on cr.crew_role_id = s1.staff_crew_role_id
                            where cr.role_name = 'security'
                         order by s1.staff_id
                         limit greatest(1, floor(st.capacity * 0.05))) s;
insert into event_staff (fest_event_id, staff_id)
select fe.fest_event_id, s.staff_id
  from fest_event fe
       inner join stage st on fe.stage_id = st.stage_id
       cross join lateral (select s1.staff_id
                             from staff s1
                                  inner join crew_role cr on cr.crew_role_id = s1.staff_crew_role_id
                            where cr.role_name in ('assistant', 'cleaner')
                         order by s1.staff_id
                         limit greatest(1, floor(st.capacity * 0.02))) s;

/*
insert into event_staff (fest_event_id, staff_id)
select x.fest_event_id, x.staff_id
	   from (select random(), *
	           from fest_event e 
	                cross join staff s
	                inner join crew_role cr on cr.crew_role_id = s.staff_crew_role_id
	          where cr.role_name <> 'technician'
	         order by 1) as x;
insert into event_staff (fest_event_id, staff_id)
select x.fest_event_id, x.staff_id
	   from (select random(), *
	           from fest_evaent e 
	                cross join staff s
	                inner join crew_role cr on cr.crew_role_id = s.staff_crew_role_id
	          where cr.role_name <> 'technician'
	            and e.fest_event_id::text in (select min(fest_event_id::text) from event_staff)
	            and s.experience_level = 'experienced'
	         order by 1) as x;
*/

-- generate 50 random rows for the 'artist' table
insert into artist (artist_name, stage_name, birth_date, website, instagram)
select a.artist_name, a.stage_name, a.birth_date, a.website, a.instagram
  from (select 'artist ' || generate_series as artist_name,
               'stagename' || generate_series as stage_name,
               make_date(1990 + (random() * 10)::int,   			-- generates years between 1990-1999
			   (random() * 11 + 1)::int,      						-- ensures month is between 1-12
			   least(28, (random() * 31 + 1)::int)) as birth_date,  -- ensures valid day
               'https://artist' || generate_series || '.com' as website, 
               '@artist' || generate_series as instagram
          from generate_series(1, 50)) a;

-- generate 10 random rows for the 'band' table
insert into band(band_name, formation_date, website, instagram)
select a.band_name, a.formation_date, a.website, a.instagram
  from (select 'group ' || generate_series as band_name, 
               make_date(2010 + (random() * 10)::int,   				-- generates years between 2010-2019
			   (random() * 11 + 1)::int,      							-- ensures month is between 1-12
			   least(28, (random() * 31 + 1)::int)) as formation_date,  -- ensures valid day
               'https://band' || generate_series || '.com' as website, 
               '@band' || generate_series as instagram
          from generate_series(1, 10)) a
limit 10;

-- generate 10 random rows for the 'band_members' table
insert into band_members(band_id, artist_id)
select b.band_id, a.artist_id
  from (select band_id from band order by random() limit 4) b
       cross join (select artist_id from artist order by random() limit 2) as a;
insert into band_members(band_id, artist_id)
select b.band_id, a.artist_id
  from (select band_id from band where not exists (select 1 from band_members m where m.band_id = band.band_id) order by random() limit 1) b
       cross join (select artist_id from artist order by random() limit 3) as a;
insert into band_members(band_id, artist_id)
select b.band_id, a.artist_id
  from (select band_id from band where not exists (select 1 from band_members m where m.band_id = band.band_id) order by random()) b
       cross join (select artist_id from artist order by random() limit 3) as a;

-- generate 50 random rows for the 'genres' table
insert into genres (artist_id, genres_name, sub_genres)
select artist_id,
       case when floor(random() * 10)::int < 2 then 'rock'
            when floor(random() * 10)::int between 2 and 3 then 'pop'
            when floor(random() * 10)::int between 4 and 6 then 'jazz'
            when floor(random() * 10)::int between 7 and 9 then 'hiphop' 
            else 'greek' 
        end as genres_name, ''
  from artist a;
insert into genres (band_id, genres_name, sub_genres)
select band_id,
       case when floor(random() * 10)::int < 2 then 'rock'
            when floor(random() * 10)::int between 2 and 3 then 'pop'
            when floor(random() * 10)::int between 4 and 6 then 'jazz'
            when floor(random() * 10)::int between 7 and 9 then 'hiphop' 
            else 'greek' 
        end as genres_name, ''
  from band a;
insert into genres (artist_id, band_id, genres_name, sub_genres)
select artist_id, band_id,
       case when genres_name = 'greek' then 'rock'
            when genres_name = 'hiphop' then 'pop'
        end as genres_name, ''
  from genres g 
 where g.genres_name in ('greek', 'hiphop');
update genres set sub_genres = genres_name || ' 1' where substring(artist_id::text, 1, 1) < '7';
update genres set sub_genres = genres_name || ' 2' where substring(artist_id::text, 1, 1) >= '7';
update genres set sub_genres = genres_name || ' 1' where substring(band_id::text, 1, 1) < '7';
update genres set sub_genres = genres_name || ' 2' where substring(band_id::text, 1, 1) >= '7';

-- generate 300 random rows for the 'visitor' table
insert into visitor (first_name, last_name, contact_info, birth_year)
select 'first' || generate_series, 'last' || generate_series, 'email' || generate_series || '@example.com', (18 + (random() * 50)::int)
   from generate_series(1, 1000) 
order by random()
limit 100 ;

-- generate 1000 random rows for the 'performance' table
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e) t1 limit 30;
-- the following inserts data for query 5
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select p.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from performance p
               inner join artist a on a.artist_id = p.artist_id
               cross join fest_event e
         where NOW()::date < a.birth_date + interval '30 years' ) t1 
	     limit 30;

insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e
         where a.artist_name like '%4') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e
         where a.artist_name like '%10') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e
         where a.artist_name like '%9') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select null, t1.band_id, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select m.band_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from band m
               cross join fest_event e) t1 limit 30;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select null, t1.band_id, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select m.band_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from band m
               cross join fest_event e
         where m.band_name like '%4') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select null, t1.band_id, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select m.band_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from band m
               cross join fest_event e
         where m.band_name like '%10') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select null, t1.band_id, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select m.band_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from band m
               cross join fest_event e
         where m.band_name like '%9') t1 limit 10;
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
	        when coalesce(tempor, 0) between 6 and 18 then 'mid'
	        else 'end'
  		end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (interval '1 hours')) as start_time,
               (select e.ending - (interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e) t1 limit 3;
-- the following inserts data for query14
insert into performance (artist_id, band_id, fest_event_id, start_time, end_time, active, p_type)
select t1.artist_id, null, t1.fest_event_id, t1.start_time, t1.end_time, case when t1.start_time > now() then true else false end as active,
       case when coalesce(tempor, 0) < 6 then 'warm up'
            when coalesce(tempor, 0) between 6 and 18 then 'mid'
            else 'end'
        end as p_type
  from (select a.artist_id, e.fest_event_id,
               (select e.starting + (random() * interval '1 hours')) as start_time,
               (select e.ending - (random() * interval '1 hours')) as end_time,
               floor(random() * 24)::int as tempor
          from artist a
               cross join fest_event e
               inner join genres g on g.artist_id = a.artist_id 
        where g.genres_name = 'rock') t1 
limit 30;


-- generate 20000 random rows for the 'performance_staff' table
insert into performance_staff (performance_id, staff_id)
select x.performance_id, x.staff_id
	   from (select random(), *
	           from performance p 
	                cross join staff s
	         order by random() limit 1000) as x;
   
-- generate 10000 random rows for the 'ticket' table
insert into ticket (fest_event_id, visitor_id, ean_code, purchase_date, is_activated, price, category, payment_method)
select t2.fest_event_id, t2.visitor_id, t2.ean_code, t2.purchase_date, 
       case when t2.starting < now() then true else false end, floor(t2.price),
       case when coalesce(tempor, 0) < 2 then 'vip'
	        when coalesce(tempor, 0) between 2 and 9 then 'general'
	        else 'backstage'
  	   end as category,
  	   case when coalesce(tempor2, 0) < 5 then 'credit card'
	        when coalesce(tempor2, 0) between 5 and 9 then 'debit card'
	        else 'bank transfer'
  	   end as payment_method
  from (select v.visitor_id, fe.fest_event_id, fe.starting,
               lpad((floor(random() * 1000000000000))::bigint::text, 13, '0') as ean_code,
               (select fe.starting + (random() * interval '2 days'))::date as purchase_date,
               random() * 200::int as price, random() * 10::int as tempor, random() * 10::int as tempor2
          from (select v.visitor_id from visitor v order by random()) v
               cross join fest_event fe) t2 order by random() limit 1000;
insert into ticket (fest_event_id, visitor_id, ean_code, purchase_date, is_activated, price, category, payment_method)
select t2.fest_event_id, t2.visitor_id, t2.ean_code, t2.purchase_date, 
       case when t2.starting < now() then true else false end, floor(t2.price),
       case when coalesce(tempor, 0) < 2 then 'vip'
	        when coalesce(tempor, 0) between 2 and 9 then 'general'
	        else 'backstage'
  	   end as category,
  	   case when coalesce(tempor2, 0) < 5 then 'credit card'
	        when coalesce(tempor2, 0) between 5 and 9 then 'debit card'
	        else 'bank transfer'
  	   end as payment_method
  from (select v.visitor_id, fe.fest_event_id, fe.starting,
               lpad((floor(random() * 1000000000000))::bigint::text, 13, '0') as ean_code,
               (select fe.starting + (random() * interval '2 days'))::date as purchase_date,
               random() * 200::int as price, random() * 10::int as tempor, random() * 10::int as tempor2
          from (select v.visitor_id from visitor v order by v.visitor_id) v
               cross join fest_event fe) t2 order by t2.visitor_id limit 300;
insert into ticket (fest_event_id, visitor_id, ean_code, purchase_date, is_activated, price, category, payment_method)
select t2.fest_event_id, t2.visitor_id, t2.ean_code, t2.purchase_date, 
       case when t2.starting < now() then true else false end, floor(t2.price),
       case when coalesce(tempor, 0) < 2 then 'vip'
	        when coalesce(tempor, 0) between 2 and 9 then 'general'
	        else 'backstage'
  	   end as category,
  	   case when coalesce(tempor2, 0) < 5 then 'credit card'
	        when coalesce(tempor2, 0) between 5 and 9 then 'debit card'
	        else 'bank transfer'
  	   end as payment_method
  from (select v.visitor_id, fe.fest_event_id, fe.starting,
               lpad((floor(random() * 1000000000000))::bigint::text, 13, '0') as ean_code,
               (select fe.starting + (random() * interval '2 days'))::date as purchase_date,
               random() * 200::int as price, random() * 10::int as tempor, random() * 10::int as tempor2
          from (select v.visitor_id from visitor v order by v.visitor_id desc) v
               cross join fest_event fe) t2 order by t2.visitor_id desc limit 300;
-- make ticket prices more realistic
update ticket
   set price = ceiling((price / ceiling((s.maxprice - s.minprice) / 5)) + 1) * ceiling((s.maxprice - s.minprice) / 5)
  from (select min(price) minprice, max(price) maxprice from ticket) s;
--this is for query 9
drop sequence if exists serial;
create sequence serial start 1;
insert into visitor (first_name, last_name, contact_info, birth_year)
select 'testvisitor1' , 'forquery9', 'contact1', 1969; 
insert into visitor (first_name, last_name, contact_info, birth_year)
select 'testvisitor2' , 'forquery9', 'contact2', 1699;
insert into ticket (fest_event_id, visitor_id, ean_code, purchase_date, is_activated, price, category, payment_method)
select fe.fest_event_id, v.visitor_id, '01234567890' || nextval('serial')::text, now()::date, false, 10, 'general', 'debit card'
  from (select fest_event_id 
          from fest_event fe1
               inner join festival f1 on f1.festival_id = fe1.festival_id
         where f1.fest_year = '2025'
       order by 1 limit 5) as fe
       cross join visitor v 
 where v.last_name like 'forquery9%';

/*-- generate 50 random rows for the 'stage_equipment' table
insert into stage_equipment (stage_id, technical_crew, speaker_req, lights_req, mics_req, consoles_req, specialeffects_req)
select s.stage_id,
	   floor(random() * 10)::int as technical_crew,
       floor(random() * 10)::int as speaker_req,
       floor(random() * 10)::int as lights_req,
       floor(random() * 10)::int as mics_req,
       floor(random() * 10)::int as consoles_req,
       floor(random() * 10)::int as specialeffects_req
  from stage s;*/
   
-- generate 20000 random rows for the 'review' table
insert into review (ticket_id, artist_performance_id, interpretation, sound_and_lights, stage_presence, organization, overall_impression)
select t1.ticket_id, t1.performance_id, 
       case when random1 < 1 then 1 when random1 > 5 then 5 else random1 end,
       case when random2 < 1 then 1 when random2 > 5 then 5 else random2 end,
       case when random3 < 1 then 1 when random3 > 5 then 5 else random3 end,
       case when random4 < 1 then 1 when random4 > 5 then 5 else random4 end,
       case when random5 < 1 then 1 when random5 > 5 then 5 else random5 end
  from (select t.ticket_id, p.performance_id, floor(random() * 6)::int as random1,
               floor(random() * 6)::int as random2, floor(random() * 6)::int as random3,
               floor(random() * 6)::int as random4, floor(random() * 6)::int as random5
          from ticket t
               inner join performance p on p.fest_event_id = t.fest_event_id) as t1
               
               
               
               
               
               
               
               
               
               
               
               
               
               