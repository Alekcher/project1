insert into analysis.dm_rfm_segments (    
    user_id,
    recency,
    frequency,
    monetary_value)
select u.id as user_id,
	   r.recency,
	   f.frequency,
	   mv.monetary_value
from analysis.users u 
left join analysis.tmp_rfm_recency r on u.id = r.user_id
left join analysis.tmp_rfm_frequency f on u.id = f.user_id
left join analysis.tmp_rfm_monetary_value mv on u.id = mv.user_id;


/*
user_id	recency	frequency	monetary_value
0	    1	    3	         4
1	    4	    3	         3
2	    2	    3	         5
3	    2	    3	         3
4	    4	    3	         3
5	    5	    5	         5
6	    1	    3	         5
7	    4	    2    	     2
8	    1	    2	         3
9	    1	    2	         2
*/