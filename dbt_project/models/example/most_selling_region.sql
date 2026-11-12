with customer_data as
(
select 
	customerid
	,country
from prod.customers 
where customerid in (select customerid from {{ source('prod', 'orders') }})
) 
,emoployee_data as
(
select 
	employeeid 
	,territoryid 
from prod.employee_territories et 
where employeeid in (select employeeid from {{ source('prod', 'orders') }})
)
select 
	regiondescription
	,uniqExact(orderid) as order_count
	,sum(unitprice*quantity*(1-discount)) as summary
from prod.orders od 
left join customer_data
using(customerid)
left join emoployee_data 
using(employeeid)
left join {{ source('prod', 'territories') }}
using(territoryid)
left join {{ source('prod', 'order_details') }} od2 
using(orderid)
left join {{ source('prod', 'regions') }} r 
using(regionid)
group by all