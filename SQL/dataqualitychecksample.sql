SELECT
    product_id,
    COUNT(*) AS missing_stock_records
FROM inventory
WHERE stock_level IS NULL
GROUP BY product_id
ORDER BY missing_stock_records DESC;