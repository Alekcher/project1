insert into analysis.tmp_rfm_monetary_value
select u.id as user_id,
	   ntile(5) over(order by sum(o.cost))  as monetary_value
from analysis.users u
left join (select t1.*
		   from analysis.orders t1
		   inner join analysis.orderstatuses t2 on t1.status = t2.id and t2.key = 'Closed')	o on u.id = o.user_id
group by 1
;