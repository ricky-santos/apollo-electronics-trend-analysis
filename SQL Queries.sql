-- How much money has been refunded for orders longer than a month?

# Sales(SUM usd_price)
# orders / orser_status ON orders.order_id = order_status.id
# when refund_ts - ship_ts is > 30 days (1 month?)
# when refunded (create helper column)

With refund_column AS (
  Select order_id,
  CASE WHEN refund_ts IS not null then 1 else 0 end as refunded
  FROM core.order_status
)
Select Round(Sum(usd_price),2)
From core.order_status
Left Join core.orders
  on orders.id = order_status.order_id
Left Join refund_column
  on refund_column.order_id = order_status.order_id
Where DATE_DIFF(refund_ts, ship_ts, day) > 30
  AND refund_column.refunded = 1

-- What products have the heighest return rates?

# products (distinct)
# avg of return rate (case when)
# join orders to oder_status

Select DISTINCT(product_name),
  ROUND(AVG(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END), 2) as refund_rate,
  Round(Avg(USD_Price),2) as AOV
FROM core.orders
Join core.order_status
  ON orders.id = order_status.order_id
group by 1
order by 2 desc

-- what is the average delivery time across the years?

# years colums (extract), group by 1
# avg (datediff) dilevery_ts, ship_ts
#left join order_status, orders.id = order_status.order_id

Select extract(Year FROM orders.purchase_ts) as purchase_year,
  avg(date_diff(delivery_ts, orders.purchase_ts, day)) as avg_delivery_time_days
FROM core.orders
Left join core.order_status
  on orders.id = order_status.order_id
group by 1
order by 1 asc

-- What is the average ship to refund time?

# datediff refund_ts, delivery_ts

Select AVG(DATE_DIFF(refund_ts, ship_ts, day)) as avg_refund_time
from core.order_status

-- What were the order counts, sales, and AOV for Macbooks sold in North America for each quarter across all years? 

# Select quarters and years, order (count)  USD price (Sum), USD price avg (AOV), 
# from orders table
# filter for NA and Macbooks
# join costumers and geo_lookup tables
# sort by asc

SELECT DATE_TRUNC(purchase_ts, quarter) as Purchase_Quarter,
  COUNT(Distinct(orders.id)) as Order_Count,
  ROUND(SUM(usd_price), 2) as Sales,
  ROUND(AVG(usd_price), 2) as AOV,
FROM core.orders
LEFT JOIN core.customers 
  on customer_id = customers.id
LEFT JOIN core.geo_lookup
  on country_code = country
WHERE geo_lookup.region = 'NA'and lower(product_name) = 'macbook air laptop'
GROUP BY 1
ORDER BY 1 asc;
