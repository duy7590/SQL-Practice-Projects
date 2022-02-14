--Print data from 3 different tables of 2018, 2019, 2020
SELECT * FROM dbo.['2018$']
SELECT * FROM dbo.['2019$']
SELECT * FROM dbo.['2020$']


--One unified dataset by using UNION. Row count has increased to 90776 rows
SELECT * FROM dbo.['2018$']
union
SELECT * FROM dbo.['2019$']
union
SELECT * FROM dbo.['2020$']


--Is hotel revenue growing?
-- Create a temporary table from these 3 tables named "hotels"

With hotels as (
SELECT * FROM dbo.['2018$']
union
SELECT * FROM dbo.['2019$']
union
SELECT * FROM dbo.['2020$']
)
select * from hotels
left join dbo.market_segment$
on hotels.market_segment = market_segment$.market_segment
left join dbo.meal_cost$
on meal_cost$.meal = hotels.meal

select arrival_date_year, hotel, round(sum((stays_in_week_nights+stays_in_weekend_nights)*adr),2)  as revenue
from hotels
group by arrival_date_year, hotel



