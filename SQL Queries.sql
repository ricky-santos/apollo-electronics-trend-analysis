-- How much money has been refunded for orders longer than a month?

# Sales
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
