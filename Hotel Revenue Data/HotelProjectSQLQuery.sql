WITH HotelData AS (
	SELECT *
	 FROM dbo.['2018$']
	UNION
	SELECT *
	 FROM dbo.['2019$']
	UNION
	SELECT *
	 FROM dbo.['2020$'])

SELECT *
 FROM HotelData
LEFT JOIN dbo.market_segment$
ON HotelData.market_segment = market_segment$.market_segment
LEFT JOIN dbo.meal_cost$
ON meal_cost$.meal = HotelData.meal

USE HotelProject
GO
WITH HotelData AS (
	SELECT *
	 FROM dbo.['2018$']
	UNION
	SELECT *
	 FROM dbo.['2019$']
	UNION
	SELECT *
	 FROM dbo.['2020$'])
SELECT 
	arrival_date_year,
	hotel,
	ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr), 2) AS StayRevenue
 FROM HotelData
 GROUP BY
	hotel,
	arrival_date_year