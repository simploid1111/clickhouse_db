{{ config(
    materialized = "table",
    engine = "MergeTree()", 
    order_by = ["customerid", "shippedmonth"],
    database = "prod",
    schema = "prod",
    alias = "customer_purchases_for_last_3_months"
) }}
with 
(
select (
toStartOfMonth(min(splitByChar('.', if(shippeddate='NULL', '1970-01-01 00:00:00', shippeddate))[1]::date)),
toStartOfMonth(max(splitByChar('.', if(shippeddate='NULL', '1970-01-01 00:00:00', shippeddate))[1]::date))
	) 
from {{ source('prod', 'orders') }}
) as arr_dt 
,orders as 
(
select 
	customerid
	,toStartOfMonth(splitByChar('.', if(shippeddate='NULL', '1970-01-01 00:00:00', shippeddate))[1]::datetime) shippedmonth
	,nullif(orderid, 0) orderid
from  {{ source('prod', 'orders') }}
group by all 
order by customerid, shippedmonth
with fill from coalesce(arr_dt.1, '1970-01-01'::date) to coalesce(arr_dt.2, '1970-01-01'::date)
step interval 1 month
)
,order_details 
as 
(
select 
	orderid
	,sum(quantity*unitprice*(1-discount)) revenue
from {{ source('prod', 'order_details') }} od 
group by all
)
,final_cte as 
(
select 
	*
	,avg(revenue) over(partition by customerid order by shippedmonth rows BETWEEN 2 preceding and current row) revenue_3_last_month
	,sum(order_count) over(partition by customerid order by shippedmonth rows BETWEEN 2 preceding and current row) order_cnt_over_3_last_month
from 
	(
	select distinct
		customerid
		,shippedmonth 
		,sum(revenue) as revenue
		,uniqExact(orderid) order_count
	from {{ source('prod', 'orders') }} 
	left join order_details 
	using(orderid)
	group by all
	) tal
)
select 
	customerid
	,shippedmonth
	,revenue_3_last_month
	,order_cnt_over_3_last_month
from final_cte 
where order_cnt_over_3_last_month > 0
