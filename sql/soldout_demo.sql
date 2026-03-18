do $$
declare 
    max_tickets int;
    now_tickets int;
    max_fest_event_id uuid;
    cur_interest int;
begin
    -- Find capacity for one fest_event
    select fe.fest_event_id, sum(s.capacity)
      into max_fest_event_id, max_tickets
      from fest_event fe
           inner join stage s on s.stage_id = fe.stage_id
    group by fe.fest_event_id
    limit 1;
    raise notice 'Total tickets for fest_event % are %', max_fest_event_id, max_tickets;
    -- Find tickets already sold for the fest_event
    select count(*)
      into now_tickets
      from ticket t
    where t.fest_event_id = max_fest_event_id;
    raise notice 'Current tickets for fest_event % are %', max_fest_event_id, now_tickets;
    -- Insert visitors for the new tickets
    insert into visitor (first_name, last_name, contact_info, birth_year)
    select 'sold first' || generate_series, 'sold last' || generate_series, 'email' || generate_series || '@example.com', (18 + (random() * 50)::int)
       from generate_series(1, max_tickets) 
    order by random()
    limit max_tickets;
    -- Insert tickets to reach stage capacities
    loop
        insert into ticket (fest_event_id, visitor_id, ean_code, purchase_date, is_activated, price, category, payment_method)
        select t2.fest_event_id, t2.visitor_id, t2.ean_code, t2.purchase_date, false, 11 as price, 'general' as category, 'debit card' as payment_method
          from (select v.visitor_id, fe.fest_event_id, fe.starting,
                       lpad((floor(random() * 1000000000000))::bigint::text, 13, '0') as ean_code,
                       fe.starting::date as purchase_date
                  from visitor v
                        cross join fest_event fe
                 where not exists (select 1 from ticket t where t.visitor_id = v.visitor_id)
                   and fe.fest_event_id = max_fest_event_id) t2 limit 1;
        select count(*)
          into now_tickets
          from ticket t
        where t.fest_event_id = max_fest_event_id;
        exit when now_tickets >= max_tickets;
    end loop;
    raise notice 'Fest_event % is soldout', max_fest_event_id;
    -- Insert an interest
    select count(*) from ticket_resale_interest tri into cur_interest where tri.fest_event_id = max_fest_event_id;
    raise notice 'Current interest before insert interest for % tickets', cur_interest;
    insert into ticket_resale_interest (buyer_id, fest_event_id, category, interest_date)
    select (select v.visitor_id from visitor v where not exists (select 1 from ticket t where t.visitor_id = v.visitor_id) limit 1) as buyer_id,
           max_fest_event_id, 'general', now();
    select count(*) from ticket_resale_interest tri into cur_interest where tri.fest_event_id = max_fest_event_id;
    raise notice 'Current interest after insert interest for % tickets', cur_interest;
    -- Insert a ticket in queue to be matched with above interest
    insert into ticket_resale_queue (ticket_id, seller_id, queue_date)
    select t.ticket_id, t.visitor_id, t.purchase_date
      from ticket t
     where t.fest_event_id = max_fest_event_id
    limit 1;
    select count(*) from ticket_resale_interest tri into cur_interest where tri.fest_event_id = max_fest_event_id;
    raise notice 'Current interest after insert queue for % tickets', cur_interest;
end $$;
