use mavenfuzzyfactory;

                               -- TRAFFIC SOURCES
-- 1 Anlaysing total sessions by content and conversion rate
SELECT 
   website_sessions.utm_content,
   COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
   COUNT(DISTINCT orders.order_id) AS total_orders,
   COUNT(DISTINCT  orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
 FROM 
   website_sessions
LEFT JOIN 
    orders
ON website_sessions.website_session_id=orders.website_session_id
GROUP BY 
    utm_content
ORDER BY 
     total_sessions DESC;
     
     -- 2 most website session coming from
SELECT 
   utm_source,
   utm_campaign,
   http_referer,
   COUNT(DISTINCT website_session_id) AS session
FROM 
   website_sessions
WHERE created_at<'2012-04-12'
GROUP BY 
    utm_source,
   utm_campaign,
   http_referer
ORDER BY 
    session DESC;
   
-- 3 calculating conversion rate from session to order to finf dbids
SELECT 
   COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
   COUNT(DISTINCT orders.order_id) AS total_orders,
   COUNT(DISTINCT  orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
 FROM 
   website_sessions
LEFT JOIN 
    orders
ON orders.website_session_id=website_sessions.website_session_id
WHERE 
   website_sessions.created_at<'2014-04-14'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
ORDER BY 
     total_sessions DESC;
     
-- 3 trend session by volume,week by gsearch and nonbrand

SELECT 
     MIN(DATE(website_sessions.created_at)) AS week_start_date,
     COUNT(website_sessions.website_session_id) AS total_Sessions
FROM 
     website_sessions
WHERE  
	website_sessions.created_at<'2012-05-10'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY
     YEAR(created_at) ,
     WEEK(created_at);
     
-- 4 conversion rate from session to orders by device type
SELECT 
    website_sessions.device_type,
   COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
   COUNT(DISTINCT orders.order_id) AS total_orders,
   (COUNT(DISTINCT  orders.order_id)*100.0/COUNT(DISTINCT website_sessions.website_session_id)) AS conversion_rate
 FROM 
   website_sessions
LEFT JOIN 
    orders
ON orders.website_session_id=website_sessions.website_session_id
WHERE 
   website_sessions.created_at<'2012-05-11'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY
       website_sessions.device_type
ORDER BY 
     total_sessions DESC;
     
     
-- 5 Weekly trend analysis on both device and mobile type
SELECT 
    MIN(DATE(created_at)) AS weekly_sessions,
    COUNT( DISTINCT CASE WHEN device_type='desktop' THEN website_session_id ELSE 0 END) AS d_Type_sessions,
	COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE 0 END) AS m_Type_sessions
FROM 
   website_sessions
WHERE 
    website_sessions.created_at<'2012-06-19'
    AND  website_sessions.created_at>'2012-04-15'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY 
   YEAR(created_at),
   WEEK(created_at);
   
   
                       -- WEBSITE CONTENT
                       
	DROP TABLE first_page_view;
                       
CREATE TEMPORARY TABLE first_page_view 
SELECT 
     website_session_id,
     MIN(website_pageview_id) AS page_views
FROM 
     website_pageviews
GROUP BY 
     website_session_id;
SELECT 
  website_pageviews.pageview_url AS first_entry,
  COUNT(DISTINCT first_page_view.page_views) AS total_page_views
FROM 
   first_page_view
LEFT JOIN 
    website_pageviews
ON
      first_page_view.page_views=website_pageviews.website_pageview_id
GROUP BY 
      website_pageviews.pageview_url;
      
-- 1 most viewed page urls and their session volumes
SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS session_volumes
FROM 
    website_pageviews
WHERE 
     created_at<'2012-06-09'
GROUP BY 
    pageview_url
ORDER BY  
    session_volumes DESC;

-- 2 Identifying top entry pages with their volumes
DROP TABLE first_view_session;

CREATE TEMPORARY TABLE first_view_session
SELECT
    website_session_id,
     MIN(website_pageview_id) AS first_viewes
 FROM
    website_pageviews
WHERE 
     created_at<'2012-06-12'
 GROUP BY 
    website_session_id;
SELECT 
    website_pageviews.pageview_url AS entry_view_page,
    COUNT(DISTINCT(first_view_session.website_session_id)) AS first_view
FROM 
     first_view_session
LEFT JOIN
     website_pageviews
ON 
   first_view_session.first_viewes=website_pageviews.website_pageview_id
GROUP BY 
     website_pageviews.pageview_url;
     
-- 3 calculating bounce rate for traffic landing on the home page
-- step 1 finding the website page views for relevant sessions
DROP TABLE first_view;
CREATE TEMPORARY TABLE first_view
SELECT 
    website_session_id,
    MIN(website_pageview_id) AS first_pv
FROM 
   website_pageviews 
WHERE 
   created_at<'2012-06-14'
GROUP BY 
   website_session_id;

SELECT * FROM first_view;

-- step 2 identifying landing page for each sessions
CREATE TEMPORARY TABLE home_landing_page
SELECT 
    first_view.website_session_id,
    website_pageviews.pageview_url AS landing_url
FROM
   first_view
LEFT JOIN
   website_pageviews
ON
 website_pageviews.website_pageview_id=first_view.first_pv
WHERE 
  website_pageviews.pageview_url='/home';

-- step 3 Counting of bouned sessions

CREATE TEMPORARY TABLE bounced_session
SELECT 
home_landing_page.website_Session_id,
home_landing_page.landing_url AS landing_page,
COUNT( website_pageviews.website_pageview_id) AS count_pages_viewed
FROM
   home_landing_page
LEFT JOIN
   website_pageviews
ON
 home_landing_page.website_session_id=website_pageviews.website_session_id
GROUP BY
    home_landing_page.website_Session_id,
     home_landing_page.landing_url 
HAVING 
   COUNT( website_pageviews.website_pageview_id)=1;
-- step 3 calculating bounce rate
SELECT 
   COUNT(DISTINCT home_landing_page.website_session_id) AS sessions,
      COUNT(DISTINCT bounced_session.website_session_id) AS bounced_sessions,
          COUNT(DISTINCT bounced_session.website_session_id)/COUNT(DISTINCT home_landing_page.website_session_id) AS bounced_rate
FROM
  home_landing_page
LEFT JOIN 
   bounced_session
ON 
  home_landing_page.website_session_id=bounced_session.website_session_id;
  

  -- 4 analysing the bouncer rate on new custom landing page
-- step1 finding out the new page launch

-- first_created_at=2012-06-19 00:35:54
-- first_website_page_view=23504
CREATE TEMPORARY TABLE fisrt_test_page_views
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS webiste_page_view
FROM
  website_pageviews
INNER JOIN
    website_sessions
ON 
  website_pageviews.website_session_id=website_sessions.website_session_id
AND
 website_sessions.created_at<'2012-07-28'
 AND 
 website_pageviews.website_pageview_id>23504
AND 
  website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY
  website_pageviews.website_session_id;
-- step 2 extracting land page from each sessions\\

CREATE TEMPORARY TABLE nonbrand_session_landing_page
SELECT 
    fisrt_test_page_views.website_session_id,
    website_pageviews.pageview_url 
FROM 
  fisrt_test_page_views
LEFT JOIN
   website_pageviews
ON
  fisrt_test_page_views.webiste_page_view=website_pageviews.website_pageview_id
WHERE
      website_pageviews.pageview_url IN('/home','/lander-1');
      
-- step 3 count of page views per session

CREATE TEMPORARY TABLE nonbrad_bounced_landing_page
SELECT 
  nonbrand_session_landing_page.website_session_id
,  nonbrand_session_landing_page.pageview_url AS landing_page,
COUNT(website_pageviews.website_pageview_id) AS couunt_pages_viewed
FROM 
    nonbrand_session_landing_page
LEFT JOIN
    website_pageviews
ON 
nonbrand_session_landing_page.website_session_id=website_pageviews.website_session_id
GROUP BY 
   nonbrand_session_landing_page.website_session_id
,  nonbrand_session_landing_page.pageview_url
HAVING
  COUNT(website_pageviews.website_pageview_id) =1;
-- step 3 calculating bouncing rate for the each landig page
SELECT 
nonbrad_bounced_landing_page.landing_page,
COUNT(DISTINCT nonbrad_bounced_landing_page.website_session_id) AS bounced_sessions,
COUNT(DISTINCT nonbrand_session_landing_page.website_session_id) AS sessions
FROM 
    nonbrad_bounced_landing_page
LEFT JOIN
  nonbrand_session_landing_page
ON
  nonbrad_bounced_landing_page.website_session_id=nonbrand_session_landing_page.website_session_id
GROUP BY
  nonbrand_session_landing_page.pageview_url;
   
-- 5 fIND paid search nonbrand traffic  landing on /home and /lander-1, trended weekly since June  1st?
-- step 1 extracting total page views and first page view in each session
CREATE TEMPORARY TABLE session_min_pv_count
  SELECT  
  website_sessions.website_session_id
,MIN(website_pageviews.website_pageview_id) AS first_view,
COUNT( website_pageviews.website_pageview_id) AS count_views
FROM
 website_sessions
LEFT JOIN 
 website_pageviews
ON 
 website_pageviews.website_session_id=website_sessions.website_session_id
 WHERE 
    website_sessions.created_at>'2012-06-01'
    AND website_sessions.created_at<'2012-08-31'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY 
     website_sessions.website_session_id;

 CREATE TEMPORARY TABLE session_count_pv_created_at    
SELECT  
session_min_pv_count.website_session_id,
session_min_pv_count.first_view,
session_min_pv_count.count_views,
website_pageviews.pageview_url AS landing_page,
website_pageviews.created_at AS session_created_at
FROM
  session_min_pv_count
LEFT JOIN
website_pageviews
ON
  session_min_pv_count.first_view=website_pageviews.website_pageview_id;
  
  SELECT 
     MIN(DATE(session_created_at)) AS week_start_date,
     COUNT(DISTINCT CASE WHEN count_views=1 THEN website_session_id ELSE NULL END)*1.0/ COUNT(DISTINCT website_session_id) AS bounce_rate,
     COUNT(DISTINCT CASE WHEN landing_page='/home' THEN website_session_id ELSE NULL END) AS home_page,
	COUNT(DISTINCT CASE WHEN landing_page='/lander-1' THEN website_session_id ELSE NULL END) AS lading_page
FROM
    session_count_pv_created_at
GROUP BY
  YEARWEEK(session_created_at);
    
    
                                               -- 1 BUILDING CONVERSION FUNNEL FROM LANDING TO THNAKYOU
CREATE TEMPORARY TABLE session_made_page_views
SELECT 
website_session_id,
MAX(to_products) AS products_page,
MAX(to_mrfuzzy) AS mrfuzzy_page,
MAX(to_cart) AS cart_page,
MAX(to_shipping) AS shipping_page,
MAX(to_billing) AS billing_page,
MAX(to_order) AS thankyou_page
FROM(
SELECT
   website_sessions.website_session_id,
   website_pageviews.pageview_url,
   CASE WHEN  website_pageviews.pageview_url='/products' THEN 1 ELSE 0 END AS to_products,
   CASE WHEN  website_pageviews.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
   CASE WHEN  website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS to_cart,
   CASE WHEN  website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS to_shipping,
   CASE WHEN  website_pageviews.pageview_url='/billing' THEN 1 ELSE 0 END AS to_billing,
   CASE WHEN  website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_order
FROM 
   website_sessions
LEFT JOIN 
   website_pageviews
ON
  website_pageviews.website_session_id=website_sessions.website_session_id
WHERE 
    website_sessions.created_at>'2012-08-05'
    AND website_sessions.created_at<'2012-09-05'
   AND website_sessions.utm_source='gsearch'
   AND website_sessions.utm_campaign='nonbrand'
GROUP BY 
website_sessions.website_session_id,
   website_pageviews.pageview_url) AS page_view_level
   GROUP BY
   website_session_id;

WITH click_through_rate AS(
SELECT 
  COUNT(DISTINCT website_session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN products_page=1 THEN website_session_id ELSE 0 END) AS product_count,
  
    COUNT(DISTINCT CASE WHEN mrfuzzy_page=1 THEN website_session_id ELSE 0 END) AS mrfuzzy_page_count,
    COUNT(DISTINCT CASE WHEN cart_page=1 THEN website_session_id ELSE 0 END) AS cart_page_count,
    COUNT(DISTINCT CASE WHEN shipping_page=1 THEN website_session_id ELSE 0 END) AS shipping_page_count,
        COUNT(DISTINCT CASE WHEN billing_page=1 THEN website_session_id ELSE 0 END) AS billing_page_count,
                COUNT(DISTINCT CASE WHEN thankyou_page=1 THEN website_session_id ELSE 0 END) AS thankyou_page_count
FROM session_made_page_views)
SELECT 
   total_sessions,
   product_count,
   product_count/total_sessions AS lander_clk_rate,
   mrfuzzy_page_count,
   mrfuzzy_page_count/product_count AS product_clk_rate,
   cart_page_count,
   cart_page_count/mrfuzzy_page_count AS mrfuzzy_clk_rate,
   shipping_page_count,
   shipping_page_count/cart_page_count AS cart_clk_rate,
   billing_page_count,
   billing_page_count/shipping_page_count AS shipping_clc_rate,
   thankyou_page_count,
   thankyou_page_count/billing_page_count AS thankyou_clk_rate
FROM 
   click_through_rate;
   
   
   -- 2.what % of sessions on those pages end up placing an order on new landing
  
  
  SELECT 
      MIN(website_pageview_id)
	FROM  
    website_pageviews
WHERE pageview_url='/billing-2';

-- step 1
SELECT
  billing_version_seen,
  COUNT(DISTINCT website_session_id) AS sessions,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(DISTINCT order_id)/ COUNT(DISTINCT website_session_id) AS billing_order_rt
  FROM(
  SELECT 
  website_pageviews.website_session_id,
  website_pageviews.pageview_url AS billing_version_seen,
  orders.order_id
FROM 
   website_pageviews
LEFT JOIN 
    orders
ON 
 website_pageviews.website_session_id=orders.website_session_id
WHERE 
   website_pageviews.website_pageview_id>53550
   AND 
     website_pageviews.pageview_url IN('/billing','/billing-2')
     AND  website_pageviews.created_at<'2012-11-10') AS billing_Session_orders
	GROUP BY billing_version_seen;
       
                    -- CHANNEL PORTFOLIO ANALYSIS

-- 1 weekly trend analysis on new launch of second paid seacrh channel
SELECT
    MIN(DATE(created_at)) AS  starting_week_date,
    COUNT(DISTINCT website_session_id) AS total_Sessions,
    COUNT(DISTINCT CASE WHEN utm_source='gsearch' THEN website_session_id ELSE 0 END) AS gsearch_Sessions,
        COUNT(DISTINCT CASE WHEN utm_source='bsearch' THEN website_session_id ELSE 0 END) AS bsearch_Sessions
FROM
    website_sessions
WHERE 
    created_at>'2012-08-22' 
    AND created_at<'2012-11-29'
    AND utm_campaign='nonbrand'
GROUP BY
   YEAR(created_at),
   WEEK(created_at);
   

-- 2 % of traffic coming on mobile fro the bsearch and gsearch
SELECT 
   utm_source,
   COUNT(DISTINCT website_session_id) AS total_Sessions,
   COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
   COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_mobile
FROM
   website_sessions
WHERE 
   utm_source IN('gsearch','bsearch')
   AND created_at>'2012-08-22'
   AND created_at<'2012-11-30'
   AND utm_campaign='nonbrand'
GROUP BY 
   utm_source;
   
   
   -- 3  nonbrand conversion rates  from session to order for gsearch and bsearch, and slice the  data by device type?

SELECT 
   website_sessions.device_type,
   website_sessions.utm_source,
   COUNT(DISTINCT website_sessions.website_session_id) AS total_Sessions,
   COUNT(DISTINCT orders.order_id) AS total_orders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
  website_sessions
LEFT JOIN
   orders
ON 
     website_sessions.website_session_id=orders.website_session_id
WHERE
   website_sessions.utm_campaign='nonbrand'
   AND website_sessions.created_at>'2012-08-22'
      AND website_sessions.created_at<'2012-09-19'     
GROUP BY
   website_sessions.device_type,
   website_sessions.utm_source;

-- 4  weekly session volume for gsearch and bsearch  nonbrand, broken down by device include a comparison metric to show bsearch as a 
-- percent of gsearch for each device

SELECT 
 MIN(DATE(created_at)) AS week_start_date,
 COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS gs_dt_sessions,
  COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS bs_dt_sessions,
  COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END)/
  COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) AS ds_gs_pct_Session,
  COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS gs_dt_mobile_Session,
  COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='moblie' THEN website_session_id ELSE NULL END) AS bs_dt_mobile_Session,
  COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END)/
  COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) AS ds_gs_pct_mobile_Session
  FROM
     website_sessions
WHERE 
   created_at>'2012-11-04'
   AND created_at<'2012-12-22'
   AND utm_campaign='nonbrand'
GROUP BY
   YEAR(created_at),
      WEEK(created_at);
      
-- 5 pull organic search, direct type in, and paid  brand search sessions by month, and show those sessions  
-- as a % of paid search nonbrand?
SELECT
YEAR(created_at) AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS non_brand,
COUNT(DISTINCT CASE WHEN channel_group='paid_brand' THEN website_session_id ELSE NULL END) AS paid_brand,
COUNT(DISTINCT CASE WHEN channel_group='paid_brand' THEN website_session_id ELSE NULL END)
/COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS brnd_non_pct,
COUNT(DISTINCT CASE WHEN channel_group='direct_type_in' THEN website_session_id ELSE NULL END) AS direct_type,
COUNT(DISTINCT CASE WHEN channel_group='direct_type_in' THEN website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS dr_non_pct,
COUNT(DISTINCT CASE WHEN channel_group='organic_Search' THEN website_session_id ELSE NULL END) AS organic_search,
COUNT(DISTINCT CASE WHEN channel_group='organic_Search' THEN website_session_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN channel_group='paid_nonbrand' THEN website_session_id ELSE NULL END) AS or_non_pct
FROM(
SELECT 
  website_session_id,
  created_at,
  CASE 
    WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_Search'
    WHEN utm_campaign='nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign='brand' THEN 'paid_brand'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
    END AS channel_group
FROM 
  website_sessions
WHERE 
  created_at<'2012-12-23') AS session_wise_brand
  GROUP BY
   YEAR(created_at) ,
MONTH(created_at);

  
                                -- BUSINESS PATTERNS AND SEASIONALITY
-- 1  take a look at 2012’s monthly and weekly volume  patterns pull session volume and order volume
SELECT  
    YEAR(website_sessions.created_at) AS year,
        MONTH(website_sessions.created_at) AS month,
        COUNT(DISTINCT website_sessions.website_session_id) AS total_Sessions,
		COUNT(DISTINCT orders.order_id) AS total_orders
FROM 
    website_sessions
LEFT JOIN
   orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE 
  website_sessions.created_at<'2013-01-01'
GROUP BY
  YEAR(website_sessions.created_at) ,
        MONTH(website_sessions.created_at);

SELECT  
    MIN(DATE(website_sessions.created_at)) AS week_start_date,
        COUNT(DISTINCT website_sessions.website_session_id) AS total_Sessions,
		COUNT(DISTINCT orders.order_id) AS total_orders
FROM 
    website_sessions
LEFT JOIN
   orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE 
  website_sessions.created_at<'2013-01-01'
GROUP BY
  YEARWEEK(website_sessions.created_at);
  
  -- 2 Could you analyze  the average website session volume, by hour of day and 
-- by day week, so that we can staff appropriately
SELECT
  hour_c,
  ROUND(AVG(CASE WHEN week_num=0 THEN total_Sessions ELSE NULL END),2) AS mon,
    ROUND(AVG(CASE WHEN week_num=1 THEN total_Sessions ELSE NULL END),2) AS tue,
      ROUND(AVG(CASE WHEN week_num=2 THEN total_Sessions ELSE NULL END),2) AS wed,
        ROUND(AVG(CASE WHEN week_num=3 THEN total_Sessions ELSE NULL END),2) AS thu,
          ROUND(AVG(CASE WHEN week_num=4 THEN total_Sessions ELSE NULL END),2) AS fri,
            ROUND(AVG(CASE WHEN week_num=5 THEN total_Sessions ELSE NULL END),2) AS sat,
              ROUND(AVG(CASE WHEN week_num=6 THEN total_Sessions ELSE NULL END),2) AS sun
              FROM(
SELECT 
   DATE(created_at) AS created_at,
   WEEKDAY(created_at) AS week_num,
   HOUR(created_at) AS hour_c,
   COUNT(DISTINCT website_session_id) AS total_Sessions
FROM
   website_sessions
WHERE 
   created_at BETWEEN '2012-09-15' AND '2012-10-15'
GROUP BY
  DATE(created_at) ,
   WEEKDAY(created_at),
   HOUR(created_at)) AS daily_analysis
GROUP BY hour_c;

                                                     -- PRODUCT LEVEL ANALYSIS
-- 1  pull monthly trends to date for number of  sales, total revenue, and total margin generated for the business
SELECT 
     YEAR(created_at) AS year,
     MONTH(created_at) AS month,
     COUNT(order_id) AS toal_orders,
     SUM(price_usd) AS total_revenue,
     SUM(price_usd-cogs_usd) AS total_margin
FROM
    orders
WHERE 
    created_at<'2013-01-04'
GROUP BY
 YEAR(created_at) ,
  MONTH(created_at);
  
  
  
  -- 2 second product back on January 6th. Can  you pull together some trended analysis? I’d like to see monthly order volume, overall conversion 
-- rates, revenue per session, and a breakdown of sales by  product, all for the time period since April 1, 2013.
SELECT
      YEAR(website_sessions.created_at) AS year,
      MONTH(website_sessions.created_at) AS month,
      COUNT(DISTINCT orders.order_id) AS total_orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS con_rate,
      SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_Session,
      COUNT(DISTINCT CASE WHEN orders.primary_product_id=1 THEN order_id ELSE NULL END) AS product_1_orders, 
        COUNT(DISTINCT CASE WHEN orders.primary_product_id=2 THEN order_id ELSE NULL END) AS product_2_orders
FROM 
   website_sessions
LEFT JOIN 
   orders
ON website_sessions.website_session_id=orders.website_session_id
WHERE 
    website_sessions.created_at<'2013-04-05' 
    AND     website_sessions.created_at>'2012-04-01'
GROUP BY
  YEAR(orders.created_at) ,
      MONTH(orders.created_at);
      
      
-- 3 Let’s look at sessions which  hit the /products page and see where they went next.  Could you please pull clickthrough rates from /products 
-- since the new product launch on January 6th 2013, by  product, and compare to the 3 months leading up to launch  as a baseline?
CREATE TEMPORARY TABLE product_page_view
SELECT
    website_pageview_id,
    website_session_id,
    created_at,
    CASE
      WHEN created_at<'2013-01-06' THEN 'A.pre_product_2'
      WHEN created_at>='2013-01-06' THEN 'B post_product_2'
      ELSE "check_logic"
      END AS time_period
FROM   
  website_pageviews
WHERE created_at<'2013-04-06' 
AND created_at>'2012-10-06'
AND pageview_url='/products';

CREATE TEMPORARY TABLE session_next_page_view
SELECT
   product_page_view.website_session_id,
   product_page_view.time_period,
   MIN(website_pageviews.website_pageview_id) AS next_page_view
FROM  
     product_page_view
LEFT JOIN 
     website_pageviews
ON product_page_view.website_session_id=website_pageviews.website_session_id
AND website_pageviews.website_pageview_id>product_page_view.website_pageview_id
GROUP BY
   product_page_view.website_session_id,
   product_page_view.time_period;
 
 CREATE TEMPORARY TABLE session_next_page_view_url
SELECT
   session_next_page_view.time_period,
   session_next_page_view.website_session_id,
   website_pageviews.pageview_url AS next_page_view_url
FROM
  session_next_page_view
LEFT JOIN
   website_pageviews
ON website_pageviews.website_pageview_id=session_next_page_view.next_page_view;
  
  SELECT
     time_period,
     COUNT(website_session_id) AS total_sessions,
     COUNT( DISTINCT CASE WHEN next_page_view_url IS NOT NULL THEN website_session_id ELSE NULL END) AS next_page,
          COUNT( DISTINCT CASE WHEN next_page_view_url IS NOT NULL THEN website_session_id ELSE NULL END)/
          COUNT(DISTINCT website_session_id) AS pct_of_next_page,
		COUNT(DISTINCT CASE WHEN next_page_view_url="/the-original-mr-fuzzy" THEN website_session_id  ELSE NULL END) AS to_mrfuzzy,
		COUNT(DISTINCT CASE WHEN next_page_view_url="/the-original-mr-fuzzy" THEN website_session_id  ELSE NULL END)
		/COUNT(DISTINCT website_session_id) AS pct_of_mrfuzzy,
		COUNT(DISTINCT CASE WHEN next_page_view_url="/the-forever-love-bear" THEN website_session_id  ELSE NULL END) AS to_lovebear,
		COUNT(DISTINCT CASE WHEN next_page_view_url="/the-forever-love-bear" THEN website_session_id  ELSE NULL END) 
        /COUNT(DISTINCT website_session_id) AS pct_of_love_bear
FROM  session_next_page_view_url
GROUP BY time_period;
          
          
          
-- 4 comparison between the two conversion funnels, for all website traffic.

CREATE TEMPORARY TABLE seesion_seeing_page
SELECT
    website_pageview_id,
    website_session_id,
    pageview_url AS page_Seen
FROM
    website_pageviews
WHERE 
 created_at<='2013-04-10' 
  AND created_at>'2013-01-06'
  AND pageview_url IN("/the-original-mr-fuzzy","/the-forever-love-bear");
  

CREATE TEMPORARY TABLE session_made_it_flag
SELECT
  website_session_id,
  CASE WHEN page_Seen='/the-original-mr-fuzzy' THEN 'mrfuzzy'
  WHEN page_Seen='//the-forever-love-bear' THEN 'lovebear'
  ELSE "check logic"
  END AS product_Seen,
  MAX(to_Cart) AS cart_made,
  MAX(to_shipping) AS shipping_made,
  MAX(to_billing) AS biiling_made,
  MAX(to_order) AS order_made
  FROM(
SELECT
   seesion_seeing_page.website_session_id,
   seesion_seeing_page.page_Seen,
   CASE WHEN website_pageviews.pageview_url='/cart' THEN 1 ELSE 0 END AS to_Cart,
	CASE WHEN website_pageviews.pageview_url='/shipping' THEN 1 ELSE 0 END AS to_shipping,
	CASE WHEN website_pageviews.pageview_url='/billing-2' THEN 1 ELSE 0 END AS to_billing,
CASE WHEN website_pageviews.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_order

FROM  
     seesion_seeing_page
LEFT JOIN 
     website_pageviews
ON website_pageviews.website_session_id=seesion_seeing_page.website_session_id
AND website_pageviews.website_pageview_id>seesion_seeing_page.website_pageview_id
GROUP BY
   seesion_seeing_page.website_session_id,
   seesion_seeing_page.page_Seen)
AS pageview_level
GROUP BY website_Session_id,
CASE WHEN page_Seen='/the-original-mr-fuzzy' THEN 'mrfuzzy'
  WHEN page_Seen='//the-forever-love-bear' THEN 'lovebear'
  ELSE "check logic"
  END;


SELECT
  product_seen,
  COUNT( DISTINCT website_session_id) AS total_Sessions,
  COUNT(DISTINCT CASE WHEN cart_made=1 THEN website_session_id ELSE NULL END) AS to_cart,
  COUNT(DISTINCT CASE WHEN shipping_made=1 THEN website_session_id ELSE NULL END) AS to_shipping, 
  COUNT(DISTINCT CASE WHEN biiling_made=1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN order_made=1 THEN website_session_id ELSE NULL END) AS to_orders
FROM 
  session_made_it_flag
GROUP BY
  product_seen;


  
                     -- CROSS SELL ANALYSIS
-- 1 compare the month before vs the month  after the change? I’d like to see CTR from the /cart page, 
-- Avg Products per Order, AOV, and overall revenue per /cart page view.
CREATE TEMPORARY TABLE session_Seeing_cart
SELECT
    CASE 
      WHEN created_at<'2013-09-25' THEN "A.pre_cross_sell"
      WHEN created_at>='2013-01-06' THEN "B. post_cross_Sell"
      ELSE " check logic"
      END AS time_period,
website_session_id AS cart_Session_id,
website_pageview_id as cart_pageview_id
FROM
   website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND "2013-10-25"
AND pageview_url='/cart';


SELECT
   session_Seeing_cart.time_period,
   session_Seeing_cart.cart_Session_id,
   MIN(website_pageviews.website_pageview_id) AS page_id_after
FROM
    website_pageviews
LEFT JOIN
   session_Seeing_cart
ON
   website_pageviews.website_session_id=session_Seeing_cart.cart_Session_id
   AND website_pageviews.website_pageview_id>session_Seeing_cart.cart_pageview_id
GROUP BY
  session_Seeing_cart.time_period,
   session_Seeing_cart.cart_Session_id
HAVING
     MIN(website_pageviews.website_pageview_id) IS NOT NULL;
     


-- 2 u please run a pre-post analysis comparing the 
-- month before vs. the month after, in terms of session-toorder conversion rate, AOV, products per order, and 
-- revenue per session?

SELECT   
   CASE 
      WHEN website_sessions.created_at<'2013-12-12' THEN "pre_post_birthday"
      WHEN website_sessions.created_at>='2013-12-12' THEN "post_birthday"
      ELSE "check"
      END AS "time period",
      COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
      COUNT(DISTINCT orders.order_id) as orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
      SUM(orders.price_usd) AS revenue,
      SUM(orders.items_purchased) AS total_products_sold,
      SUM(orders.price_usd) /COUNT(DISTINCT orders.order_id) AS avg_order_value,
	SUM(orders.items_purchased) /COUNT(DISTINCT orders.order_id) AS price_per_product,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_Session
FROM
   website_sessions
   LEFT JOIN
      orders
ON
  website_sessions. website_session_id=orders.website_session_id
  WHERE 
  website_sessions.created_at BETWEEN '2013-11-12' AND "2014-01-12"
  GROUP BY
   CASE 
      WHEN website_sessions.created_at<'2013-12-12' THEN "pre_post_birthday"
      WHEN website_sessions.created_at>='2013-12-12' THEN "post_birthday"
      ELSE "check"
      END ;
      
      
	-- 3 monthly product refund rates, by  product, and confirm our quality issues are now fixed
SELECT
   YEAR(order_items.created_at) AS year,
      MONTH(order_items.created_at) AS month,
      COUNT(DISTINCT CASE WHEN order_items.product_id=1 THEN order_items.order_item_id ELSE NULL END ) AS order_1,
            COUNT(DISTINCT CASE WHEN order_items.product_id=1 THEN order_item_refunds.order_item_refund_id ELSE NULL END )/
      COUNT(DISTINCT CASE WHEN order_items.product_id=1 THEN order_items.order_item_id ELSE NULL END ) AS p1_refund_rt,
COUNT(DISTINCT CASE WHEN order_items.product_id=2 THEN order_items.order_item_id ELSE NULL END ) AS order_2,
            COUNT(DISTINCT CASE WHEN order_items.product_id=2 THEN order_item_refunds.order_item_refund_id ELSE NULL END )/
      COUNT(DISTINCT CASE WHEN order_items.product_id=2 THEN order_items.order_item_id ELSE NULL END ) AS p2_refund_rt,
      COUNT(DISTINCT CASE WHEN order_items.product_id=3 THEN order_items.order_item_id ELSE NULL END ) AS order_3,
            COUNT(DISTINCT CASE WHEN order_items.product_id=2 THEN order_item_refunds.order_item_refund_id ELSE NULL END )/
      COUNT(DISTINCT CASE WHEN order_items.product_id=2 THEN order_items.order_item_id ELSE NULL END ) AS p3_refund_rt,
      COUNT(DISTINCT CASE WHEN order_items.product_id=4 THEN order_items.order_item_id ELSE NULL END ) AS order_4,
            COUNT(DISTINCT CASE WHEN order_items.product_id=4 THEN order_item_refunds.order_item_refund_id ELSE NULL END )/
      COUNT(DISTINCT CASE WHEN order_items.product_id=4 THEN order_items.order_item_id ELSE NULL END ) AS p4_refund_rt
FROM
    order_items
    LEFT JOIN
      order_item_refunds
	ON order_items.order_item_id=order_item_refunds.order_item_id
WHERE order_items.created_at<'2014-10-15'
GROUP BY
   YEAR(order_items.created_at),
      MONTH(order_items.created_at);

                             -- USER LEVEL ANALYSIS
-- 1 Comparing new vs. repeat sessions by channel 
SELECT
    CASE WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com','https://www.bsearch.com') THEN "organic_search"
    WHEN utm_campaign ='nonbrand' THEN "paid_nonbrad"
    WHEN utm_campaign ="brand" THEN "paid_brad"
    WHEN utm_source IS NULL AND http_referer IS NULL THEN "direct_type_in"
    WHEN utm_source='socialbook' THEN "paid_socialbook"
    ELSE "check once"
    END AS paid_Channels,
    COUNT(CASE WHEN is_repeat_session=0 THEN website_session_id ELSE NULL END) AS new_Session,
        COUNT(CASE WHEN is_repeat_session=1 THEN website_session_id ELSE NULL END) AS repeat_Session
    FROM website_sessions
    WHERE
      created_at<'2014-11-05'
      AND created_at>'2014-01-01'
	GROUP BY 1
    ORDER BY 3 DESC;
    
    -- 2 comparison of conversion rates and revenue per session for repeat sessions vs new sessions. 
   SELECT
       website_sessions.is_repeat_session,
       COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
       COUNT(DISTINCT orders.order_id) AS orders,
       COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
       SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_Session
       FROM website_sessions
       LEFT JOIN orders
       ON website_sessions.website_session_id=orders.website_session_id
       WHERE website_sessions.created_at<'2014-11-08'
       AND website_sessions.created_at>'2014-01-01'
       GROUP BY website_sessions.is_repeat_session;
       
      