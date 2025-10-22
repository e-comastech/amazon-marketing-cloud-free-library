-- AMC query to calculate attributed sales and ACOS by US state
WITH sales_data AS (
    SELECT
        i.iso_state_province_code AS state,
        i.user_id,
        SUM(i.total_cost / 100000) AS total_cost  -- cost is stored in millicents
    FROM dsp_impressions AS i
    GROUP BY 1, 2
),
conversion_data AS (
    SELECT
        c.user_id,
        SUM(c.product_sales) AS sales
    FROM amazon_attributed_events_by_conversion_time AS c
    GROUP BY 1
)
SELECT
    s.state,
    COUNT(DISTINCT s.user_id) AS unique_users,
    SUM(c.sales) AS total_sales,
    SUM(s.total_cost) AS total_cost,
    (SUM(s.total_cost) / NULLIF(SUM(c.sales), 0)) * 100 AS acos_percentage
FROM sales_data s
JOIN conversion_data c
  ON s.user_id = c.user_id
GROUP BY 1
HAVING COUNT(DISTINCT s.user_id) >= 100  
