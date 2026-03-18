select f.fest_name, f.fest_year, coalesce(sum(t.price), 0) as revenue_total, 
	   coalesce(sum(case when t.payment_method = 'debit card' then coalesce(t.price, 0) else 0 end), 0) as revenue_debit_card, 
	   coalesce(sum(case when t.payment_method = 'credit card' then coalesce(t.price, 0) else 0 end), 0) as revenue_credit_card, 
	   coalesce(sum(case when t.payment_method = 'bank transfer' then coalesce(t.price, 0) else 0 end), 0) as revenue_bank_transfer
  from festival f
       left join fest_event fe on fe.festival_id = f.festival_id
       left join ticket t on fe.fest_event_id  = t.fest_event_id
group by f.fest_name, f.fest_year
order by f.fest_name, f.fest_year
