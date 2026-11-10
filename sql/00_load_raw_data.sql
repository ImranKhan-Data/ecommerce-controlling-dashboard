SELECT order_id,
       order_status,
       order_purchase_timestamp
FROM raw_orders
WHERE order_status = 'canceled'
ORDER BY order_purchase_timestamp DESC
LIMIT 10;