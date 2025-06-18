-- NIFTY 50 Analysis
USE NIFTY_50;
-- -------------------------------------------------------
-- Query 1
-- Biggest daily gain (24 hr) (Top 10)

SELECT _Date,
	  change_in_percent
FROM nifty_analysis
ORDER BY change_in_percent DESC
LIMIT 10;

-- -------------------------------------------------------
-- Query 2
-- Biggest daily losses (24 hrs) (Top 10)

SELECT _Date,
	  change_in_percent
FROM nifty_analysis
ORDER BY change_in_percent ASC
LIMIT 10;

-- -------------------------------------------------------
-- Query 3
-- Biggest intraday gains (Closing - opening)

SELECT _Date,
	  ROUND((closing-opening)/opening*100,2) AS Intraday_gains
FROM nifty_analysis
ORDER BY intraday_gains DESC
LIMIT 10;

-- -------------------------------------------------------
-- Query 4
-- Biggest intraday losses (Closing - opening)

SELECT _Date,
	  ROUND((closing-opening)/opening*100,2) AS intraday_losses
FROM nifty_analysis
ORDER BY intraday_losses ASC
LIMIT 10;

-- -------------------------------------------------------
-- Creating a view for yearly gains (it would make our upcoming queries easier and smoother

CREATE VIEW Yearly_gains AS
SELECT DISTINCT YEAR(_Date) AS _Year,
FIRST_VALUE (closing) OVER(PARTITION BY YEAR(_date)) AS opening,
LAST_VALUE (closing) OVER(PARTITION BY YEAR(_date)) AS closing,
ROUND(LAST_VALUE (closing) OVER(PARTITION BY YEAR(_date))-FIRST_VALUE (closing) OVER(PARTITION BY YEAR(_date)),3) AS Absolute_Gain_or_loss,
ROUND(LAST_VALUE (closing) OVER(PARTITION BY YEAR(_date))-FIRST_VALUE (closing) OVER(PARTITION BY YEAR(_date)),3)/FIRST_VALUE (closing) OVER(PARTITION BY YEAR(_date))*100 AS percent_gain_or_loss
FROM nifty_analysis;

-- -------------------------------------------------------
-- Query 5
-- Selecting yearly gains according to gain% (CAUTION: 2014 and 2024 are not full calendar years)

SELECT _Year,
	   ROUND(percent_gain_or_loss,3) AS percent_gain_or_loss
FROM yearly_gains
ORDER BY percent_gain_or_loss DESC;

-- -------------------------------------------------------
-- Query 6
-- Average yearly Gain or loss % 

SELECT ROUND(AVG(percent_gain_or_loss),3) AS percent_gain_or_loss
FROM yearly_gains;

-- -------------------------------------------------------
-- Query 7
-- Average yearly Gain or loss %  (excluding 2014,2024)

SELECT ROUND(AVG(percent_gain_or_loss),3) AS percent_gain_or_loss
FROM yearly_gains
WHERE _year NOT IN (2014,2024);

-- -------------------------------------------------------
-- Query 8
-- Average yearly Gain or loss %  (excluding 2020,2021 to remove Covid induced outliers)

SELECT ROUND(AVG(percent_gain_or_loss),3) AS percent_gain_or_loss
FROM yearly_gains
WHERE _year NOT IN (2020,2021);

-- -------------------------------------------------------
-- Creating a view for MONTHLY gains (it would make our upcoming queries easier and smoother

CREATE VIEW Monthly_gains AS
SELECT DISTINCT DATE_FORMAT(_date,'%m-%Y') AS Months,
	   MONTH(_date) AS Month_number,
	   MONTHNAME(_date) AS Month_name,
       YEAR(_date) AS Years,
	   FIRST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  ) AS Opening,
       LAST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  ) AS Closing,
       ROUND(LAST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  )- FIRST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  ),3)  AS Absolute_gain,
       ROUND(LAST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  )- FIRST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  ),3)/FIRST_VALUE(closing) OVER( PARTITION BY  DATE_FORMAT(_date,'%m-%Y')  )*100 AS Percentage_gain
FROM
nifty_analysis;


-- -------------------------------------------------------
-- Query 9
-- M-o-M gains

SELECT  Month_number,
        Month_name,
		Years,
		ROUND(Percentage_gain,3) AS Monthly_gains
FROM Monthly_gains
ORDER BY  Years;

-- -------------------------------------------------------
-- Query 10
-- Selecting months on basis of avg_monthly gains

SELECT  Month_number,
		Month_name,
		ROUND(AVG(Percentage_gain),3) AS avg_Monthly_gains
FROM Monthly_gains
GROUP BY Month_number, Month_name
ORDER BY avg_Monthly_gains DESC;

-- -------------------------------------------------------
-- Query 11
-- Selecting months on basis of avg_monthly gains (Removing Covid Based Outliers)

SELECT  Month_number,
		Month_name,
		ROUND(AVG(Percentage_gain),3) AS avg_Monthly_gains
FROM Monthly_gains
WHERE YearS NOT IN (2020, 2021)
GROUP BY Month_number, Month_name
ORDER BY avg_Monthly_gains DESC;

-- -------------------------------------------------------
-- Query 12
-- Average P/E, P/B, Div_yield (10 years)

SELECT  ROUND(AVG(pe),3) AS PE_ratio_avg,
		ROUND(AVG(pb),3) AS PB_ratio_avg,
        ROUND(AVG(Div_yield_percent),3) AS Div_yield_avg
FROM nifty_analysis;

-- -------------------------------------------------------
-- Query 13
-- Average P/E, P/B, Div_yield (10 years) (Excluding 2020 and 2021 to remove covid induced outliers)

SELECT  ROUND(AVG(pe),3) AS PE_ratio_avg,
		ROUND(AVG(pb),3) AS PB_ratio_avg,
        ROUND(AVG(Div_yield_percent),3) AS Div_yield_avg
FROM nifty_analysis
WHERE YEAR(_date) NOT IN (2020,2021);

-- -------------------------------------------------------
-- Query 14
-- Average P/E, P/B, Div_yield for every year from 2014-2024

SELECT  YEAR(_Date) as Years,
		ROUND(AVG(pe),3) AS PE_ratio_avg,
		ROUND(AVG(pb),3) AS PB_ratio_avg,
        ROUND(AVG(Div_yield_percent),3) AS Div_yield_avg
FROM nifty_analysis
GROUP BY YEAR(_date);

-- -------------------------------------------------------
-- Query 15
-- Highest and Lowest P/E (in last 10 years)

SELECT _date AS Date,
       pe,
	   CASE
			WHEN PE=(SELECT MAX(PE) 
					 FROM nifty_analysis) THEN 'MAX'
			ELSE 'MIN'
	   END AS Valuation
FROM nifty_analysis
WHERE PE=(SELECT MAX(PE) 
					 FROM nifty_analysis)
		OR 
	  PE=(SELECT MIN(PE) 
					 FROM nifty_analysis);

-- -------------------------------------------------------
-- Query 16
-- Highest and Lowest P/B (in last 10 years)

SELECT _date AS Date,
       pb,
	   CASE
			WHEN PB=(SELECT MAX(PB) 
					 FROM nifty_analysis) THEN 'MAX'
			ELSE 'MIN'
	   END AS Valuation
FROM nifty_analysis
WHERE PB=(SELECT MAX(PB) 
					 FROM nifty_analysis)
		OR 
	  PB=(SELECT MIN(PB) 
					 FROM nifty_analysis);

-- -------------------------------------------------------
-- Query 17
-- Highest and Lowest Dividend yield (in last 10 years)

SELECT _date AS Date,
       div_yield_percent,
	   CASE
			WHEN  div_yield_percent=(SELECT MAX( div_yield_percent) 
					 FROM nifty_analysis) THEN 'Highest'
			ELSE 'Lowest'
	   END AS _Status
FROM nifty_analysis
WHERE  div_yield_percent=(SELECT MAX( div_yield_percent) 
					 FROM nifty_analysis)
		OR 
	   div_yield_percent=(SELECT MIN( div_yield_percent) 
					 FROM nifty_analysis);
                     
-- -------------------------------------------------------
-- Query 18
-- Top 10 most expensive days according to PE

SELECT _date,
	   pe
FROM nifty_analysis
ORDER BY pe DESC
LIMIT 10;

-- -------------------------------------------------------
-- Query 19
-- Top 10 most cheapest days according to PE

SELECT _date,
	   pe
FROM nifty_analysis
ORDER BY pe ASC
LIMIT 10;

-- -------------------------------------------------------
-- Query 20
-- Top 10 most Expensive days according to PB

SELECT _date,
	   pb
FROM nifty_analysis
ORDER BY pb DESC
LIMIT 10;

-- -------------------------------------------------------
-- Query 21
-- Top 10 most cheapest days according to PB

SELECT _date,
	   pb
FROM nifty_analysis
ORDER BY pb ASC
LIMIT 10;

-- -------------------------------------------------------
-- Query 22
-- M-o-M change in P/E, P/B, Dividend Yield

SELECT DISTINCT DATE_FORMAT(_date,'%m-%Y') AS months,
	   ROUND(AVG(pe),3) AS PE_ratio_avg,
	   ROUND(AVG(pb),3) AS PB_ratio_avg,
	   ROUND(AVG(Div_yield_percent),3) AS Div_yield_avg
FROM nifty_analysis
GROUP BY months;

-- DONE-----------------------------------------------------------------------------------------












 





