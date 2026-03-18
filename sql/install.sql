create extension if not exists "uuid-ossp";

drop table if exists ticket_resale_queue;
drop table if exists ticket_resale_interest;
drop table if exists review;
drop table if exists ticket;
drop table if exists visitor;
drop table if exists performance_staff;
drop table if exists event_staff;
drop table if exists performance;
drop table if exists genres;
drop table if exists band_members;
drop table if exists band;
drop table if exists artist;
drop table if exists staff;
drop table if exists fest_event;
drop table if exists stage_crew;
drop table if exists stage_equipment;
drop table if exists stage;
drop table if exists festival;
drop table if exists location;
drop table if exists equipments;
drop table if exists crew_role;

create table location (
    location_id uuid primary key default uuid_generate_v4(),
    address text not null,
    latitude decimal(9,6) not null,
    longitude decimal(9,6) not null,
    city varchar(100) not null,
    country varchar(100) not null,
    continent varchar(50) not null
);

create table festival (
    festival_id uuid primary key default uuid_generate_v4(),
    fest_name varchar(255) not null,
    fest_year int not null,
    start_date date not null,
    end_date date not null,
    location_id uuid not null,
    foreign key (location_id) references location(location_id)
);

create table stage (
    stage_id uuid primary key default uuid_generate_v4(),
    stage_name varchar(255) not null,
    stage_description text not null,
    capacity int not null
);

create table equipments (
    equip_id int not null generated always as identity primary key,
	equip_type varchar(20) not null
);

create table stage_equipment (
	stage_id uuid not null,
	stage_equip_id int not null,
	equip_quantity int not null default 0,
	primary key (stage_id, stage_equip_id),
	foreign key (stage_equip_id) references equipments (equip_id)
);

create table crew_role (
    crew_role_id int not null generated always as identity primary key,
	role_name varchar(50)
);

create table stage_crew (
	stage_id uuid not null,
	stage_crew_role_id int not null,
	crew_quantity int not null default 0,
	primary key (stage_id, stage_crew_role_id),
	foreign key (stage_crew_role_id) references crew_role (crew_role_id)
);

create table fest_event (
    fest_event_id uuid primary key default uuid_generate_v4(),
    festival_id uuid not null,
    stage_id uuid not null,
    starting timestamp not null,
    ending  timestamp not null,
    active bool not null default false,
    has_resalable_tickets bool default false,
    foreign key (festival_id) references festival(festival_id),
    foreign key (stage_id) references stage(stage_id)
);

create table staff (
    staff_id uuid primary key default uuid_generate_v4(),
    staff_name varchar(255) not null,
    birth_date date not null,
    staff_crew_role_id int not null,
    experience_level varchar(50) check (experience_level in ('intern', 'beginner', 'intermediate', 'experienced', 'expert')),
	foreign key (staff_crew_role_id) references crew_role (crew_role_id)
);

create table event_staff (
    event_staff_id uuid primary key default uuid_generate_v4(),
    fest_event_id uuid not null,
    staff_id uuid not null,
    foreign key (staff_id) references staff(staff_id),
    foreign key (fest_event_id) references fest_event(fest_event_id)
);

create table artist (
    artist_id uuid primary key default uuid_generate_v4(),
    artist_name varchar(255) not null,
    stage_name varchar(255),
    birth_date date not null,
    website text,
    instagram text
);

create table band (
    band_id uuid primary key default uuid_generate_v4(),
    band_name varchar(255) not null,
    formation_date date,
    website text,
    instagram text
);

create table band_members (
    band_id uuid not null,
    artist_id uuid not null,
    primary key (band_id, artist_id),
    foreign key (band_id) references band(band_id),
    foreign key (artist_id) references artist(artist_id)
);

create table genres (
    genres_id uuid primary key default uuid_generate_v4(),
    artist_id uuid null,
    band_id uuid null,
    genres_name text not null,
    sub_genres text not null,
    foreign key (artist_id) references artist(artist_id),
    foreign key (band_id) references band(band_id)
);

create table visitor (
    visitor_id uuid primary key default uuid_generate_v4(),
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    contact_info text not null,
    birth_year int not null
);

create table performance (
    performance_id uuid primary key default uuid_generate_v4(),
    p_type varchar(50) not null,
    start_time timestamp not null,
    end_time timestamp not null,
    artist_id uuid null,
    band_id uuid null,
    fest_event_id uuid not null,
    active boolean not null,
    foreign key (artist_id) references artist(artist_id),
    foreign key (band_id) references band(band_id),
    foreign key (fest_event_id) references fest_event(fest_event_id)
);

create table performance_staff (
    performance_staff_id uuid primary key default uuid_generate_v4(),
    performance_id uuid not null,
    staff_id uuid not null,
    foreign key (performance_id) references performance(performance_id),
    foreign key (staff_id) references staff(staff_id)
);

create table ticket (
    ticket_id uuid primary key default uuid_generate_v4(),
    fest_event_id uuid not null,
    visitor_id uuid not null,
    category varchar(50) check (category in ('general', 'vip', 'backstage')),
    purchase_date date not null,
    price decimal(10,2) not null,
    payment_method varchar(50) check (payment_method in ('credit card', 'debit card', 'bank transfer')),
    ean_code varchar(13) unique not null,
    is_activated boolean default false,
    foreign key (fest_event_id) references fest_event(fest_event_id),
    foreign key (visitor_id) references visitor(visitor_id)
);

create table ticket_resale_queue (
    queue_id uuid primary key default uuid_generate_v4(),
    ticket_id uuid unique not null,
    seller_id uuid not null,
    queue_date timestamp default now(),
    foreign key (ticket_id) references ticket(ticket_id),
    foreign key (seller_id) references visitor(visitor_id)
);

create table ticket_resale_interest (
    interest_id uuid primary key default uuid_generate_v4(),
    buyer_id uuid not null,
    fest_event_id uuid not null,
    category varchar(50),
    interest_date timestamp default now(),
    foreign key (buyer_id) references visitor(visitor_id),
    foreign key (fest_event_id) references fest_event(fest_event_id)
);

create table review (
    review_id uuid primary key default uuid_generate_v4(),
    ticket_id uuid not null,
    artist_performance_id uuid not null,
    interpretation int check (interpretation between 1 and 5),
    sound_and_lights int check (sound_and_lights between 1 and 5),
    stage_presence int check (stage_presence between 1 and 5),
    organization int check (organization between 1 and 5),
    overall_impression int check (overall_impression between 1 and 5),
    foreign key (ticket_id) references ticket(ticket_id),
    foreign key (artist_performance_id) references performance(performance_id)
);

-- fest_year must be unique
drop index if exists idx_festival_year;
create unique index idx_festival_year on festival (fest_year);
-- location must be unique
drop index if exists idx_festival_location;
create unique index idx_festival_location on festival (location_id);

-- every technician can work one or two times a day
create or replace function technician_less_than_three() returns trigger as
$body$
declare invalid int;
begin
    select count(*)
      into invalid
      from performance_staff ps
           inner join performance p on ps.performance_id = p.performance_id
           inner join performance pn on new.performance_id = pn.performance_id
     where ps.staff_id = new.staff_id
       and pn.start_time::date = p.start_time::date;
    if (invalid > 1) then
        raise notice 'Failed. Each technician must work up to twice a day.';
        return null;
    else
        raise notice 'Passed. This technician works less than twice a day.';
        return new;
    end if;
end;
$body$
language plpgsql;

drop trigger if exists tr_technician_less_than_three on performance_staff;
create trigger tr_technician_less_than_three
 before insert on performance_staff
 for each row
 execute procedure technician_less_than_three();

-- function that finds if an artist exist in fest_year or not
-- makes the trigger for performance more easy to be read
drop function if exists exist_artits_in_year;
create or replace function exist_artits_in_year(partist_id uuid, pfest_year int) returns int as
$body$
declare cnt int;
begin
    select count(*)
      into cnt
      from performance p
           left join artist a1 on a1.artist_id = p.artist_id
           left join band_members b on b.band_id = p.band_id
           left join artist a2 on a2.artist_id = b.artist_id
           inner join fest_event fe on fe.fest_event_id = p.fest_event_id
           inner join festival f on f.festival_id = fe.festival_id
     where coalesce(a1.artist_id, a2.artist_id) = partist_id
       and f.fest_year = pfest_year;
    if (cnt > 0) then
        return 1;
    else
        return 0;
    end if;
end;
$body$
language plpgsql;

-- artist can not appear in 3 consecutive years
-- each performance must have either artist or band filled
-- each artist cannot perform in two or more stages at the same time (as artist or as band_member)
-- each artist cannot perform more than 3 hours in each performance
-- each performance must start and end between festival event time limits
-- break between performances must be between 5 and 30 minutes
CREATE OR REPLACE FUNCTION performance_check() RETURNS TRIGGER AS
$BODY$
declare event_starting timestamp;
declare event_ending timestamp;
declare max_end timestamp;
declare min_start timestamp;
declare countartist int;
declare bartist_id uuid;
declare current_year int;
declare overlapped int;
BEGIN
select count(1)
  into overlapped
  from performance p    
 where p.fest_event_id = new.fest_event_id 
       and (new.start_time between p.start_time and p.end_time
   	   or p.start_time between new.start_time and new.end_time);
if (overlapped > 0) then
	raise notice 'Failed. Performances overlap';
	return null;
end if;
select f.fest_year
  into current_year
 from festival f
      inner join fest_event fe on f.festival_id = fe.festival_id
where fe.fest_event_id = new.fest_event_id;
if (new.artist_id is null) then
    for bartist_id in (select artist_id from band_members where band_id = new.band_id) loop
        if (exist_artits_in_year(bartist_id, current_year - 1) = 1) then
            if (exist_artits_in_year(bartist_id, current_year - 2) = 1 or exist_artits_in_year(bartist_id, current_year + 1) = 1) then
                raise notice 'Failed. 3 or more consecutive';
                return null;
            end if;
        else 
            if (exist_artits_in_year(bartist_id, current_year + 1) = 1 and exist_artits_in_year(bartist_id, current_year + 2) = 1) then
                raise notice 'Failed. 3 or more consecutive';
                return null;
            end if;
        end if;
    end loop;
end if;
select count(*)
  into countartist
  from (select p.artist_id
          from performance p
         where (new.start_time between p.start_time and p.end_time  
                or p.start_time between new.start_time and new.end_time)
            and p.artist_id is not null
        union all
        select bm.artist_id
          from performance p
               inner join band_members bm on bm.band_id = p.band_id
         where (new.start_time between p.start_time and p.end_time  
            or p.start_time between new.start_time and new.end_time)) as t1 
               inner join (select new.artist_id
                           union all
                           select artist_id
                             from band_members
                            where new.band_id is not null
                              and band_id = new.band_id) as t2 on t2.artist_id is not null and t1.artist_id = t2.artist_id;
 if (countartist = 0) then
    if (new.artist_id is null and new.band_id is null) or (new.artist_id is not null and new.band_id is not null) then
        RAISE NOTICE 'Failed. No valid performer';
        return null;
    else
        if (new.end_time > new.start_time + interval '3 hours') then
            RAISE NOTICE 'Failed. Max duration is 3h';
            return null;
        else
            select fe.starting, fe.ending 
              into event_starting, event_ending
              from fest_event fe
             where fest_event_id = new.fest_event_id;
            if (event_starting > new.start_time or event_ending < new.end_time)  then
                RAISE NOTICE 'Failed. Out of event bounds';
                return null;
            else 
                 select max(end_time)
                   into max_end
                   from performance p
                  where p.fest_event_id = new.fest_event_id 
                    and p.end_time < new.start_time;
                 select min(start_time)
                   into min_start
                   from performance p
                  where p.fest_event_id = new.fest_event_id 
                    and p.start_time > new.end_time;
                 if (((new.start_time - interval '30 minutes' < max_end and max_end < new.start_time - interval '5 minutes') or max_end is null) and 
                    ((new.end_time - interval '30 minutes' < min_start and min_start < new.end_time - interval '5 minutes') or min_start is null)) then
					 	RAISE NOTICE 'Passed. Valid performance';
                     	return new;
                 else 
                     RAISE NOTICE 'Failed. Out of performance bounds';
                     return null;
                 end if;
            end if; 
        end if; 
    end if;
 else 
     RAISE NOTICE 'Failed. There is an artist that appears in two or more stages at the same time';
     return null;
 end if;
END
$BODY$  
language plpgsql;

drop trigger if exists valid_performance_checker on performance;
CREATE TRIGGER valid_performance_checker
 BEFORE INSERT ON performance
 FOR EACH ROW
EXECUTE PROCEDURE performance_check();

-- each festival cannot exceed 13 hours per date
-- each fest_event cannot exceed 12 hours 
CREATE OR REPLACE FUNCTION valid_event_check() RETURNS TRIGGER AS
$BODY$
declare minst timestamp;
        maxend timestamp; 
        overlapped int;
BEGIN
select min(e.starting), max(e.ending)
  into minst, maxend
  from fest_event e
 where e.starting::date = new.starting::date;
if (minst is null or new.starting < minst) then
  minst = new.starting;
end if;
if (maxend is null or new.ending > maxend) then
  maxend = new.ending;
end if;     
if (minst + interval '13 hours' < maxend) then
    RAISE NOTICE 'Failed. Festival longer than 13h per day.';
    return null;
end if;
select count(1)
  into overlapped
  from fest_event fe    
 where fe.stage_id = new.stage_id
/*  the first 2 conditions in the following if statement verify that the new and old events do not overlap and the third verifies that the duration does not exceed 12 hours  */
   and (new.starting between fe.starting and fe.ending
    or fe.starting between new.starting and new.ending);
if (overlapped = 0) then 
    if (new.ending > new.starting + interval '12 hours') then 
        RAISE NOTICE 'Failed. Fest event exceeds 12h.';
        return null;
    end if;
    RAISE NOTICE 'Passed. Valid fest_event';
    return new;
else
    RAISE NOTICE 'Failed. Due to overlapping.';
    return null;
end if;
END;
$BODY$
language plpgsql;

drop trigger if exists valid_event on fest_event;
CREATE TRIGGER valid_event
 BEFORE INSERT ON fest_event
 FOR EACH ROW
EXECUTE PROCEDURE valid_event_check();

-- function to activate resale queue
drop function if exists activate_resale_queue;
create or replace function activate_resale_queue(pfest_event_id uuid) returns int as
$body$
begin
    update fest_event fe SET has_resalable_tickets = true where fe.fest_event_id = pfest_event_id;
    return 1;
end;
$body$
language plpgsql;

-- each visitor can buy one ticker per fest_event
-- tickets can not exceed stage capacity
-- vip tickets can not exceed 10% of stage capacity
-- if tickets sold = stage capacity activate resale queue
CREATE OR REPLACE FUNCTION check_ticket() RETURNS TRIGGER AS
$BODY$
declare vip_count int; 
        total_count int;
        stage_capacity int;
        dummy int;
BEGIN
     IF EXISTS (SELECT 1 
                  FROM ticket t  
                 WHERE t.visitor_id = NEW.visitor_id
                   AND t.fest_event_id = NEW.fest_event_id) THEN
        RAISE NOTICE 'Failed. This visitor already has a ticket for this event';
        return null;
     ELSE
        select count(*), sum(case when t.category = 'vip' then 1 else 0 end)
          into total_count, vip_count
          from ticket t
         where t.fest_event_id = new.fest_event_id;
        select s.capacity
          into stage_capacity
          from stage s
               inner join fest_event e on e.stage_id = s.stage_id
                                      and new.fest_event_id = e.fest_event_id;
        total_count = total_count + 1;
        if (vip_count is null) then
            vip_count = 0;
        end if; 
        if (new.category = 'vip') then
            vip_count = vip_count + 1;
        end if;
        if (total_count = stage_capacity) then
            RAISE NOTICE 'resale queue activated';
            select 1 into dummy from activate_resale_queue(new.fest_event_id);
        end if;
        if (vip_count <= stage_capacity / 10 and total_count <= stage_capacity) then
            RAISE NOTICE 'Passed. Valid ticket.';
            return new;
        else
            RAISE NOTICE 'Failed. Capacity out of bounds';
            return null;
        end if;
    END IF;
END;
$BODY$
language plpgsql;

CREATE or replace TRIGGER vip_ticket_insert
 BEFORE INSERT ON ticket
 FOR EACH ROW
 EXECUTE PROCEDURE check_ticket();

-- ticket can be in resale queue only if resale is activated
-- if there is interest match it and do not insert new
-- if there is no interest insert in queue
CREATE OR REPLACE FUNCTION resale_queue() RETURNS TRIGGER AS
$BODY$
declare queue_is_active bool;
        current_fe uuid;
        current_cat varchar(50);
        current_buyer uuid;
        current_interest uuid;
BEGIN
select has_resalable_tickets
  into queue_is_active
  from fest_event fe
       inner join ticket t on fe.fest_event_id = t.fest_event_id
 where t.ticket_id = new.ticket_id; 
if (queue_is_active = false) then
    raise notice 'Failed. Queue is inactive'; 
    return null;
else
    select t.fest_event_id, t.category
      into current_fe, current_cat
      from ticket t
     where t.ticket_id = new.ticket_id;
    select tri.interest_id, tri.buyer_id
      into current_interest, current_buyer
      from ticket_resale_interest tri
     where tri.fest_event_id = current_fe and tri.category = current_cat
     order by tri.interest_date limit 1;
    if (current_interest is not null) then
        delete from ticket_resale_interest where interest_id = current_interest;
        update ticket SET visitor_id = current_buyer where ticket_id = new.ticket_id;
        raise notice 'Passed. Sucessfully sold.';
        return null;
    else
        raise notice 'Passed. Inserted in queue';
        return new;
    end if;
end if;
END;
$BODY$
language plpgsql;

-- ticket can be in resale interest only if resale is activated
-- if there is ticket in queue match it and do not insert new
-- if there is no ticker in queue insert in interest
CREATE or replace TRIGGER resale_queue_insert
 BEFORE INSERT ON ticket_resale_queue
 FOR EACH ROW
EXECUTE PROCEDURE resale_queue();

CREATE OR REPLACE FUNCTION resale_interest() RETURNS TRIGGER AS
$BODY$
declare queue_is_active bool;
declare queue_found uuid;
declare ticket_found uuid;
BEGIN
select has_resalable_tickets
  into queue_is_active
  from fest_event fe
 where fe.fest_event_id = new.fest_event_id; 
if (queue_is_active = false) then
    raise notice 'Failed. Queue is inactive'; 
    return null;
else
    select q.queue_id, q.ticket_id
      into queue_found, ticket_found
      from ticket_resale_queue q
           inner join ticket t on t.ticket_id = q.ticket_id
           inner join fest_event fe on fe.fest_event_id = t.fest_event_id
     where fe.fest_event_id = new.fest_event_id and t.category = new.category
    order by q.queue_date limit 1;
    if (queue_found is not null) then
        delete from ticket_resale_queue where queue_id = queue_found;
        update ticket SET visitor_id = buyer_id where ticket_id = ticket_found;  
        raise notice 'Passed. Sucessfully bought';  
        return null;
    else
    raise notice 'Passed. Inserted in queue';
    return new;
    end if;
end if;
END
$BODY$
language plpgsql;
 
CREATE or replace TRIGGER resale_interest_insert
 BEFORE INSERT ON ticket_resale_interest
 FOR EACH ROW
 EXECUTE PROCEDURE resale_interest();

CREATE OR REPLACE FUNCTION deny_festival_upd_del() RETURNS TRIGGER AS
$BODY$
BEGIN
    Raise notice 'The action you are attempting to perform is not allowed';
    return null;
END
$BODY$
language plpgsql;

CREATE or replace TRIGGER no_festival_updates_or_deletes
BEFORE update or delete ON festival
FOR EACH ROW
EXECUTE PROCEDURE deny_festival_upd_del();

CREATE OR REPLACE FUNCTION deny_event_delete() RETURNS TRIGGER AS
$BODY$
BEGIN
    Raise notice 'The action you are attempting to perform is not allowed';
    return null;
END
$BODY$
language plpgsql;

CREATE or replace TRIGGER no_fest_events_deletes
BEFORE delete ON fest_event
FOR EACH ROW
EXECUTE PROCEDURE deny_event_delete();

-- every technician can work one or two times a day
create or replace function acticate_fest_event() returns trigger as
$body$
declare staffed int;
begin
    if not new.active then
        return new;
    end if;
    select count(*)
      into staffed
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
                   inner join stage sg on sg.stage_id = fe.stage_id
             where fe.fest_event_id = new.fest_event_id) as t1
     where t1.security_crew >= t1.security_need
       and t1.assistant_crew >= t1.assistant_need;
    if (staffed > 0) then
        raise notice 'Passed. Festival event is fully staffed';
        return new;
    else
        raise notice 'Failed. Festival event does not have necessary staff';
        return null;
    end if;
end;
$body$
language plpgsql;

drop trigger if exists tr_acticate_fest_event on fest_event;
create trigger tr_acticate_fest_event
 before update of active on fest_event
  for each row
 execute procedure acticate_fest_event();

drop index if exists idx_ticket_visitor_id;
drop INDEX if exists idx_review_ticket_id;
drop index if exists idx_artist_name;
drop INDEX if exists idx_performance_artist_id;
drop INDEX if exists idx_performance_band_id;
drop INDEX if exists idx_review_perf_id;
CREATE INDEX idx_artist_name ON artist(artist_name);
CREATE INDEX idx_ticket_visitor_id ON ticket(visitor_id);
CREATE INDEX idx_review_ticket_id ON review(ticket_id);
CREATE INDEX idx_performance_artist_id ON performance(artist_id);
CREATE INDEX idx_performance_band_id on performance(band_id);
CREATE INDEX idx_review_perf_id ON review(artist_performance_id);

 