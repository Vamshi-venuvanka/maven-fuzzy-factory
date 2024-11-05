USE mavenfuzzyfactory;

/*irst, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter 
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it. */
SELECT
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM
    website_sessions
LEFT JOIN
    orders
ON 
       website_sessions.website_session_id=orders.website_session_id
GROUP BY 
  YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
    
/*Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we 
launched, for session-to-order conversion rate, revenue per order, and revenue per session.*/
CREATE TEMPORARY TABLE efficiencyimprovements
   SELECT
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    SUM(orders.price_usd) AS revenue
FROM
    website_sessions
LEFT JOIN
    orders
ON 
       website_sessions.website_session_id=orders.website_session_id
GROUP BY 
  YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);
    
SELECT
      year,
      quarter,
      orders/sessions AS ses_ord_con_rate,
      revenue/orders AS rev_ord_conv_rate,
      revenue/sessions AS rve_sess_conv_rate
FROM 
   efficiencyimprovements;
    
  
  
  /* ’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch 
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in? */
SELECT 
    YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source='gsearch' AND website_sessions.utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_non_brand,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source='bsearch' AND website_sessions.utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_non_brand,
COUNT(DISTINCT CASE WHEN  website_sessions.utm_campaign='brand' THEN orders.order_id ELSE NULL END) AS brand,
COUNT( CASE WHEN website_sessions.utm_source IS NULL  AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_type_search,
COUNT( CASE WHEN website_sessions.utm_source IS NULL  AND website_sessions.http_referer IS  NULL THEN orders.order_id ELSE NULL END) AS direct_type_in
FROM
    website_sessions
LEFT JOIN
    orders
ON 
       website_sessions.website_session_id=orders.website_session_id
GROUP BY 
  YEAR(website_sessions.created_at),
    QUARTER(website_sessions.created_at);


/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_nonbrand_conv_rt, 
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_search_conv_rt,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_conv_rt,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY YEAR(website_sessions.created_at),
	QUARTER(website_sessions.created_at)
ORDER BY YEAR(website_sessions.created_at),
	QUARTER(website_sessions.created_at)
;

/* 5 We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality*/
SELECT
   YEAR(created_at) AS year,
   MONTHNAME(created_at) AS month,
   SUM(CASE
      WHEN product_id=1 THEN price_usd ELSE NULL END ) AS mrfuzzy_rev,
SUM(CASE
      WHEN product_id=1 THEN price_usd-cogs_usd ELSE NULL END ) AS mrfuzzy_margin,
SUM(CASE
      WHEN product_id=2 THEN price_usd ELSE NULL END ) AS lovebear_rev,
SUM(CASE
      WHEN product_id=2 THEN price_usd-cogs_usd ELSE NULL END ) AS lovebear_margin,
SUM(CASE
      WHEN product_id=3 THEN price_usd ELSE NULL END ) AS birthday_rev,
SUM(CASE
      WHEN product_id=3 THEN price_usd-cogs_usd ELSE NULL END ) AS birthday_margin,
SUM(CASE
      WHEN product_id=4 THEN price_usd ELSE NULL END ) AS hudson_River_rev,
SUM(CASE
      WHEN product_id=4 THEN price_usd-cogs_usd ELSE NULL END ) AS hudson_River_margin,
SUM(price_usd) AS revenue,
SUM(price_usd-cogs_usd ) AS margin
FROM
    order_items 
GROUP BY
   YEAR(created_at) ,
   MONTH(created_at)
;


/* Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products 
page, and show how the % of those sessions clicking through another page has changed over time, along with 
a view of how conversion from /products to placing an order has improved */
CREATE TEMPORARY TABLE products_Session_pageview
SELECT 
     website_session_id,
     website_pageview_id,
     created_at
FROM
   website_pageviews
WHERE 
    website_pageviews.pageview_url ='/products';
  
  CREATE TEMPORARY TABLE product_Session_next_page_view
  SELECT
       products_Session_pageview.website_session_id,
       products_Session_pageview.website_pageview_id,
       products_Session_pageview.created_at,
       MIN(website_pageviews.website_pageview_id) AS pageview_after_products
FROM
   products_Session_pageview
LEFT JOIN
   website_pageviews
ON
  products_Session_pageview.website_session_id=website_pageviews.website_session_id
  AND 
 website_pageviews.website_pageview_id>products_Session_pageview.website_pageview_id
 GROUP BY
   products_Session_pageview.website_session_id,
       products_Session_pageview.website_pageview_id,
       products_Session_pageview.created_at;
SELECT
   YEAR(product_Session_next_page_view.created_at) AS year,
   MONTHNAME(product_Session_next_page_view.created_at) AS month_name,
   COUNT(DISTINCT product_Session_next_page_view.website_session_id) AS sessions,
   COUNT(DISTINCT pageview_after_products)/
             COUNT(DISTINCT product_Session_next_page_view.website_session_id) AS pct_Clicking_through,
COUNT(DISTINCT orders.order_id) /COUNT(DISTINCT product_Session_next_page_view.website_session_id) AS conv_prod_to_others
FROM
  product_Session_next_page_view
LEFT JOIN
   orders
ON 
orders.website_session_id=product_Session_next_page_view.website_session_id
GROUP BY
   YEAR(product_Session_next_page_view.created_at) ,
   MONTHNAME(product_Session_next_page_view.created_at);
   
   /* 7.We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell 
item). Could you please pull sales data since then, and show how well each product cross-sells from one another?*/
CREATE TEMPORARY TABLE primary_products

SELECT 
	order_id, 
    primary_product_id, 
    created_at AS ordered_at
FROM orders 
WHERE created_at > '2014-12-05' -- when the 4th product was added (says so in question)
;


SELECT 
	primary_product_id, 
    COUNT(DISTINCT order_id) AS total_orders, 
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM(
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0) AS cross_selling -- only bringing in cross-sells;

GROUP BY 
primary_product_id;
   