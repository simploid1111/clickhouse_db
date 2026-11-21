{{ config(
    materialized = "view",
    engine = "MergeTree()", 
    order_by = ["orderid"],
    database = "prod",
    alias = "orders_aggregated"
) }}
select 
	coalesce(orderid, 10000) orderid
	,groupArray((productid, unitprice, quantity, discount)) prod_up_quan_disc
from {{ source('prod', 'order_details') }} 
group by all