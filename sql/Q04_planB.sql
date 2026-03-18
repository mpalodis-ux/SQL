--query4
drop index if exists idx_artist_name;
drop INDEX if exists idx_performance_artist_id;
drop INDEX if exists idx_performance_band_id;
drop INDEX if exists idx_review_perf_id;
CREATE INDEX idx_artist_name ON artist(birth_date);
CREATE INDEX idx_performance_artist_id ON performance(fest_event_id);
CREATE INDEX idx_performance_band_id on performance(band_id);
CREATE INDEX idx_review_perf_id ON review(ticket_id);
set enable_seqscan = false;
EXPLAIN (ANALYZE, BUFFERS)
select coalesce(a.artist_name, b.band_name) as name, AVG(r.interpretation) as interpretation, AVG(r.overall_impression) as overall_impression
  from review r 
       inner join performance p on p.performance_id = r.artist_performance_id
       left join artist a on a.artist_id = p.artist_id and p.artist_id is not null
       left join band b on b.band_id = p.band_id and p.band_id is not null
 where a.artist_name = 'artist 1'
group by coalesce(a.artist_name, b.band_name)
order by 1

