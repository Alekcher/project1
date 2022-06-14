insert into analysis.tmp_rfm_recency
select u.id as user_id,
	   ntile(5) over(order by max(coalesce(o.order_ts, '2020-01-01 00:00:00'::date)))  as recency
from analysis.users u
left join (select t1.*
		   from analysis.orders t1
		   inner join analysis.orderstatuses t2 on t1.status = t2.id and t2.key = 'Closed')	o on u.id = o.user_id
group by 1
;