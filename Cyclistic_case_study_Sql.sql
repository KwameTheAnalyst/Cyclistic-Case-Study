
--About Company

--In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.

--Until now, Cyclistic�s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships.

--    Customers who purchase single-ride or full-day passes are referred to as casual riders.
--    Customers who purchase annual memberships are Cyclistic members.

--Cyclistic�s finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, Moreno believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a solid opportunity to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.

--Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the team needs to

--    better understand how annual members and casual riders differ,
--    Why casual riders would buy a membership, and
--    How digital media could affect their marketing tactics. Moreno and her team are interested in analyzing the Cyclistic historical bike trip data to identify trends


--Statement of Business Task

--This project conducts a comprehensive analysis of the usage patterns and behaviors of annual members and casual riders within the Cyclistic bike-sharing program. 
--The primary objective is to identify key distinctions in how these two user segments engage with the service. 
--By understanding the differences, the goal is to inform the development of targeted marketing strategies aimed at converting casual riders into annual members. 
--The underlying motivation is the financial insight provided by the finance team, highlighting the increased profitability associated with annual memberships compared to casual rides. 
--Ultimately, my analysis aims to provide actionable insights that can be leveraged to enhance Cyclistic's marketing approach and drive the conversion of casual riders into more profitable annual members.


-- Change data type to INT
ALTER TABLE CyclisticCaseStudy.dbo.Divvy_Trips_2020_Q1
ALTER COLUMN start_station_id nvarchar(50)

ALTER TABLE CyclisticCaseStudy.dbo.Divvy_Trips_2020_Q1
ALTER COLUMN end_station_id nvarchar(50)

ALTER TABLE CyclisticCaseStudy.dbo.april_202004
ALTER COLUMN start_station_id nvarchar(50)

ALTER TABLE CyclisticCaseStudy.dbo.april_202004
ALTER COLUMN end_station_id nvarchar(50)

-- lets merge the files into one table using UNION
SELECT *
INTO CyclisticCaseStudy.dbo.cyclistic_table_2020
FROM
(
    SELECT * FROM CyclisticCaseStudy.dbo.Divvy_Trips_2020_Q1
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.april_202004
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.may_202005
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.june_202006
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.july_202007
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.aug_202008
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.sept_202009
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.oct_202010
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.nov_202011
    UNION
    SELECT * FROM CyclisticCaseStudy.dbo.dec_202012
) AS Cyclistic_Data_2020

SELECT TOP 10 *
FROM
	CyclisticCaseStudy.dbo.cyclistic_table_2020;

SELECT COUNT(*)
FROM CyclisticCaseStudy.dbo.cyclistic_table_2020

-- Transform data

	-- Creat new columns
	-- Add 'rider_length' column and update with date difference

ALTER TABLE CyclisticCaseStudy.dbo.cyclistic_table_2020
Add rider_length int

Update CyclisticCaseStudy.dbo.cyclistic_table_2020 
SET rider_length = DATEDIFF(MINUTE, started_at, ended_at);

	-- Add 'day_of_week' column and update with number of day

ALTER TABLE CyclisticCaseStudy.dbo.cyclistic_table_2020
Add day_of_week int

Update CyclisticCaseStudy.dbo.cyclistic_table_2020 
SET day_of_week = DATEPART(DW, started_at);

-- Time of day
ALTER TABLE CyclisticCaseStudy.dbo.cyclistic_table_2020
Add time_of_day int

Update CyclisticCaseStudy.dbo.cyclistic_table_2020 
SET time_of_day = DATEPART(HOUR, started_at);

-- change column name time_of_day to hour_of_day
EXEC sp_RENAME 'CyclisticCaseStudy.dbo.cyclistic_table_2020.time_of_day', 'hour_of_day', 'COLUMN'; 



-- Summary data, mean, max of rider_length
-- avg ride length is 24, max ride length is 156450

SELECT
	AVG(rider_length) AS rider_length,
	MAX(rider_length) AS max_ride_length
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020

--	
SELECT TOP 10 *
FROM CyclisticCaseStudy.dbo.cyclistic_table_2020

-- HOW annual members and casual riders differ?

-- ORGANIZE DATA

-- What is the average ride length of user types
	-- Annual members spend less time riding. This can mean they are riding faster.
	-- Casual members spend more time riding. This can mean they are riding slower.
SELECT
	member_casual, 
	AVG(rider_length) avg_ride_length,
	MAX(rider_length) max_ride_length
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY member_casual


-- What is the daily average distances(time) travelled by each group?
-- Customers spend more time riding on sundays, and for each day, casual members riding for longer hours.
	-- Sunday will be a good time for marketing to target riders.

SELECT 
	day_of_week,
	member_casual,
	AVG(rider_length) ride_length
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY day_of_week, member_casual
ORDER BY day_of_week, ride_length DESC


-- number of rides by day of week
-- Annual members make more requests than casual members

SELECT 
	day_of_week,
	member_casual,
	COUNT(ride_id) num_of_rides
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY day_of_week, member_casual
ORDER BY day_of_week, num_of_rides DESC


-- The fact that annual members make more requests than casual members is consistent with the
-- other fact that, casual members ride slow and annual members ride faster.
-- Annual members may be incentivised to ride faster.
-- Casual members may be lacking the motivation to ride faster.

-- We can also investigate the type of bike used by these groups to understand why the different groups use them for different distances.

--	
SELECT TOP 10 *
FROM CyclisticCaseStudy.dbo.cyclistic_table_2020
--

-- How many many times was each ride type used during the year?
-- docked bikes was used the most: 2966322 times, followed by Electric bikes: 504745 and classic bikes: 70616
SELECT 
	rideable_type, 
	COUNT(ride_id) num_of_rides
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY rideable_type

-- what ride types do either members use more?
-- Docked_bike is the most used, followed by electric bikes and classic bikes
-- Annual members are the biggest users of all the bike categories
SELECT 
	rideable_type, 
	member_casual, 
	COUNT(ride_id) num_of_rides
FROM CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY rideable_type, member_casual
ORDER BY num_of_rides DESC


-- how many casual and annual members are there?
-- there are 2174924 annual members and 1366550 casual members
-- There are more annual members than casual members confirms why annual members are the biggest users
SELECT 
	member_casual, 
	COUNT(DISTINCT ride_id) number
FROM CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY member_casual
ORDER BY number DESC


-- lets check the time spent on each ride_type
-- The average ride time of casual members is longer than that of annual members no matter the type of bike
SELECT 
	rideable_type, 
	member_casual, 
	AVG(rider_length) as avg_ride_time
FROM 
	CyclisticCaseStudy.dbo.cyclistic_table_2020
GROUP BY rideable_type, member_casual
ORDER BY rideable_type, avg_ride_time DESC


--Conclusion

-- A large proportion of the market is dominated by annual members. Remember this was why finance initially indicated
-- that they are more profitable.

-- To answer the questions asked earlier:
-- HOW annual members and casual riders differ?
	-- Annual members ride faster, and more request compared to casual members.
-- WHY casual riders would buy a membership?
	-- Influence the behavior of casual members to ride faster
-- HOW digital media could affect their marketing tactics. 
	-- Digital media can be used to influence the behavior casual members.
		-- To focus on the health Benefits
		-- Save cost on fuel and time around traffic congestion.

--Marketing team should target the riders on weekends. 

