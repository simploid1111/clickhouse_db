
-- Use the `ref` function to select from other models
select 
	employeeid
	,lastname
	,firstname
	,title
	,shipcountry
	,order_count
	,customer_count
	,last_order_dt
	,first_order_dt
from 
( 
select 
	employeeid 
	,shipcountry
	,uniqExact(orderid) order_count 
	,uniqExact(customerid) customer_count
	,max(orderdate) as last_order_dt
	,min(orderdate) as first_order_dt
from {{  source('prod', 'orders')  }}
group by all
) a
left join 
(
select 
	employeeid
	,lastname
	,firstname
	,title 
from {{  source('prod', 'employees')  }}
) e
using(employeeid)




















