CREATE or replace VIEW analysis.orders AS 
with actual_order_status as (
select order_id,
	   status_id 
from (
select order_id, status_id, row_number() over (partition by order_id order by dttm desc) as rn
from production.orderstatuslog) l 
where rn = 1
)

SELECT o.order_id,
       o.order_ts,
       o.user_id,
       o.bonus_payment,
       o.payment,
       o."cost",
       o.bonus_grant,
       a.status_id as status
FROM production.orders o
join actual_order_status a on o.order_id = a.order_id;