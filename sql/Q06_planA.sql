drop index if exists idx_ticket_visitor_id;
drop INDEX if exists idx_review_ticket_id;
CREATE INDEX idx_ticket_visitor_id ON ticket(visitor_id);
CREATE INDEX idx_review_ticket_id ON review(ticket_id);
set enable_seqscan = false;
EXPLAIN (ANALYZE)
select fe.fest_event_id, fe.starting, fe.ending, v.last_name, AVG(r.overall_impression) as overall_impression
  from visitor v
       inner join ticket t on t.visitor_id = v.visitor_id
       inner join fest_event fe on t.fest_event_id = fe.fest_event_id
       inner join review r on r.ticket_id = t.ticket_id
 where v.visitor_id = (select v1.visitor_id 
                         from visitor v1 
                              inner join ticket t1 on t1.visitor_id = v1.visitor_id
                              inner join review r1 on r1.ticket_id = t1.ticket_id limit 1)
group by fe.fest_event_id, fe.starting, fe.ending, v.last_name
