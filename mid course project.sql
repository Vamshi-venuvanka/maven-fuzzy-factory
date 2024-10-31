use mavenfuzzyfactory;
-- 1 Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions  
-- and orders so that we can showcase the growth there? 

SELECT
   YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
   COUNT(DISTINCT website_sessions.website_session_id) AS total_Sessions,
   COUNT(DISTINCT orders.order_id)  AS total_orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM 
   website_sessions
LEFT JOIN 
    orders
ON
  website_sessions.website_session_id=orders.website_session_id
WHERE 
    website_sessions.created_at<'2012-11-27'
    AND website_sessions.utm_source='gsearch'
GROUP BY
  YEAR(website_sessions.created_at),
  MONTH(website_sessions.created_at);
  
-- 2 Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and 
-- brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
SELECT
   YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
   COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='brand' THEN website_sessions.website_session_id ELSE 0 END) AS total_brand_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE 0 END) AS total_nonbrand_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='nonbrand' THEN orders.order_id ELSE 0 END) AS total_nonbrand_order_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign='brand' THEN orders.order_id ELSE 0 END) AS total_brand_order_Sessions
FROM 
   website_sessions
LEFT JOIN 
    orders
ON
  website_sessions.website_session_id=orders.website_session_id
WHERE 
    website_sessions.created_at<'2012-11-27'
    AND website_sessions.utm_source='gsearch'
GROUP BY
  YEAR(website_sessions.created_at),
  MONTH(website_sessions.created_at);
  
  -- 3 While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device 3 type? 
  -- I want to flex our analytical muscles a little and show the board we really know our traffic sources
  SELECT
   YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
   COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN website_sessions.website_session_id ELSE 0 END) AS total_mobile_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN website_sessions.website_session_id ELSE 0 END) AS total_desktop_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN orders.order_id ELSE 0 END) AS total_mobile_order_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN orders.order_id ELSE 0 END) AS total_dektop_order_Sessions
FROM 
   website_sessions
LEFT JOIN 
    orders
ON
  website_sessions.website_session_id=orders.website_session_id
WHERE 
    website_sessions.created_at<'2012-11-27'
    AND website_sessions.utm_source='gsearch'
    AND website_sessions.utm_campaign='nonbrand'
GROUP BY
  YEAR(website_sessions.created_at),
  MONTH(website_sessions.created_at);
  
  -- 4 I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from  Gsearch.
  -- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels
  
  SELECT DISTINCT 
     utm_source,
     utm_campaign,
     http_referer
	FROM website_Sessions
WHERE created_at<'2012-11-27';

SELECT
   YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
   COUNT(DISTINCT CASE WHEN website_sessions.utm_source='gsearch' THEN website_sessions.website_session_id ELSE 0 END) AS total_gsearch_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_source='bsearch' THEN website_sessions.website_session_id ELSE 0 END) AS total_bseacrh_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND  website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE 0 END) AS direct_type_in_Sessions,
      COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND  website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE 0 END) AS organic_search_Sessions
FROM 
   website_sessions
WHERE 
    website_sessions.created_at<'2012-11-27'
GROUP BY
  YEAR(website_sessions.created_at),
  MONTH(website_sessions.created_at);
  
  
  
  -- 5 I’d like to tell the story of our website performance improvements over the course of the first 8 months.
  -- Could you pull session to order conversion rates, by month
SELECT 
    YEAR(website_sessions.created_at) AS year,
    MONTH(website_sessions.created_at) AS month,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS convesrion_rate
FROM 
  website_sessions
  LEFT JOIN
     orders
ON 
  website_sessions.website_session_id=orders.website_session_id
WHERE
  website_sessions.created_at<'2012-11-27'
GROUP BY
    YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at);


-- 6 For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR 
-- from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
CREATE TEMPORARY TABLE first_page_views
SELECT
 website_pageviews.website_session_id,
 MIN(website_pageviews.website_pageview_id) AS first_page_views
 FROM
   website_pageviews
INNER JOIN
  website_sessions
ON  website_pageviews.website_session_id=website_sessions.website_session_id
AND 
   website_pageviews.website_pageview_id>=23504
   AND  website_sessions.created_at<'2012-11-27'
   AND  website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY
   website_pageviews.website_session_id;   

CREATE 	TEMPORARY TABLE nonbrand_session_landing_pages
SELECT 
   first_page_views.website_session_id,
   website_pageviews.pageview_url AS landing_pages
FROM
   first_page_views
LEFT JOIN
   website_pageviews
ON
  first_page_views.website_session_id=website_pageviews.website_session_id
WHERE
  website_pageviews.pageview_url IN('/home','/lander-1');
  
  CREATE TEMPORARY TABLE nonbrand_session_oredr_pages
  SELECT 
  nonbrand_session_landing_pages.website_session_id,
  nonbrand_session_landing_pages.landing_pages,
  orders.order_id
  FROM
  nonbrand_session_landing_pages
  LEFT JOIN
     orders
ON nonbrand_session_landing_pages.website_session_id=orders.website_session_id;


SELECT
   landing_pages,
   COUNT(DISTINCT website_session_id) AS sessions,
   COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conversion_rates
FROM
  nonbrand_session_oredr_pages
GROUP BY   
   landing_pages;
   
   
   -- 7 For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each 
-- of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
CREATE TEMPORARY TABLE session_first_landing_page
SELECT 
   website_session_id,
  MAX(homepage) AS saw_homepage,
MAX(custom_lander) AS saw_customlander,
MAX(products_page) AS saw_productpage,
MAX(mrfuzzy_page) AS saw_mrfuzzy,
MAX(cart_page) AS saw_cartpage,
MAX(shipping_page) AS saw_shippingpage,
MAX(billing_page) AS saw_billingpage,
MAX(thankyou_page) AS saw_thankyoupage
FROM(
SELECT
	website_sessions.website_session_id, 
    website_pageviews.pageview_url, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.utm_source = 'gsearch' 
	AND website_sessions.utm_campaign = 'nonbrand' 
    AND website_sessions.created_at < '2012-07-28'
		AND website_sessions.created_at > '2012-06-19'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at) AS total_views_page
GROUP BY 
   website_session_id;
   
   
   SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_customlander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN saw_productpage = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN saw_mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN saw_cartpage = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN saw_shippingpage = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN saw_billingpage = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN saw_thankyoupage = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_first_landing_page 
GROUP BY segment;


SELECT
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage'
        WHEN saw_customlander = 1 THEN 'saw_custom_lander'
        ELSE 'uh oh... check logic' 
	END AS segment, 
	COUNT(DISTINCT CASE WHEN saw_productpage = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN saw_mrfuzzy = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_productpage = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN saw_cartpage = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_mrfuzzy = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
    COUNT(DISTINCT CASE WHEN saw_shippingpage = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_cartpage = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN saw_billingpage = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_shippingpage = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN saw_thankyoupage = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_billingpage = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM session_first_landing_page
GROUP BY segment;



-- 8 I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from the test 
-- (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions 
-- for the past month to understand monthly impact.


SELECT
	billing_version_seen, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    SUM(price_usd)/COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
 FROM( 
SELECT 
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_version_seen, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews 
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' -- prescribed in assignment
	AND website_pageviews.created_at < '2012-11-10' -- prescribed in assignment
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')) AS billing_pagevies_data
    GROUP BY billing_version_seen;
    
    
    -- $22.83 revenue per billing page seen for the old version
-- $31.34 for the new version
-- LIFT: $8.51 per billing page view
SELECT 
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month

-- 1,194 billing sessions past month
-- LIFT: $8.51 per billing session
-- VALUE OF BILLING TEST: $10,160 over the past month
