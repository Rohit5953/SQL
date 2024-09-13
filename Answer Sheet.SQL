--SQL Advance Case Study


--Q1--BEGIN 

SELECT State, Date, Quantity
	FROM FACT_TRANSACTIONS AS FT
	JOIN DIM_LOCATION AS DL
	ON FT.IDLocation=DL.IDLocation
	WHERE FT.Quantity>0 AND (FT.Date>='2005-01-01' AND FT.Date<=GETDATE())
	ORDER BY Date;


--Q1--END

--Q2--BEGIN

	SELECT * FROM FACT_TRANSACTIONS
	SELECT * FROM DIM_MANUFACTURER
	SELECT * FROM DIM_LOCATION

	With cte as 
	(SELECT Manufacturer_Name,Country, State, SUM(Quantity) AS Qty
	FROM DIM_LOCATION AS DL
	JOIN FACT_TRANSACTIONS AS FT
	ON DL.IDLocation=FT.IDLocation
	JOIN DIM_MODEL AS DMO
	ON DMO.IDModel=FT.IDModel
	JOIN DIM_MANUFACTURER AS DM
	ON DM.IDManufacturer=DMO.IDManufacturer
	WHERE DL.Country LIKE 'US' AND Manufacturer_Name LIKE 'SAMSUNG'
	GROUP BY Manufacturer_Name,Country, State)
	SELECT * FROM cte WHERE Qty=(SELECT MAX(cte.Qty) FROM cte);


--Q2--END

--Q3--BEGIN      
	
	SELECT Model_Name, ZipCode, State, count(*) AS No_Of_Transactions 
	FROM FACT_TRANSACTIONS AS FT
	JOIN DIM_LOCATION AS DL
	ON DL.IDLocation = FT.IDLocation
	JOIN DIM_MODEL AS DMO
	ON FT.IDModel = DMO.IDModel
	GROUP BY Model_Name, ZipCode, State




--Q3--END

--Q4--BEGIN

SELECT Manufacturer_Name, Model_Name, Unit_price 
FROM DIM_MODEL AS DMO
JOIN DIM_MANUFACTURER AS DM
ON DMO.IDManufacturer = DM.IDManufacturer
WHERE Unit_price=(SELECT MIN(Unit_price) FROM DIM_MODEL);




--Q4--END

--Q5--BEGIN

SELECT Manufacturer_Name, Model_Name AS Model, SUM(Quantity) AS Total_Qty, SUM(TotalPrice)/SUM(Quantity) AS Average
FROM FACT_TRANSACTIONS AS FT JOIN
DIM_MODEL AS DMO ON FT.IDModel = DMO.IDModel JOIN
DIM_MANUFACTURER AS DM ON DM.IDManufacturer = DMO.IDManufacturer
WHERE Manufacturer_Name IN 
( SELECT TOP 5 Manufacturer_Name FROM FACT_TRANSACTIONS AS FT JOIN
DIM_MODEL AS DMO ON FT.IDModel = DMO.IDModel JOIN
DIM_MANUFACTURER AS DM ON DM.IDManufacturer = DMO.IDManufacturer
GROUP BY Manufacturer_Name ORDER BY SUM(Quantity) DESC)
GROUP BY Manufacturer_Name, Model_Name ORDER BY Average DESC






--Q5--END

--Q6--BEGIN


SELECT Customer_Name, DATE, AVG(FT.TOTALPRICE) AS AVG_Amt
	FROM DIM_CUSTOMER AS DC
	JOIN FACT_TRANSACTIONS AS FT
	ON DC.IDCustomer=FT.IDCustomer
	WHERE FT.Date>='2009-01-01' AND FT.Date<'2010-01-01'
	GROUP BY Customer_Name, Date
	HAVING  AVG(FT.TOTALPRICE)>500;





--Q6--END
	
--Q7--BEGIN  
	
	WITH
  Ranking (Model_Name, RN) AS (
    SELECT Model_Name,
      RANK() OVER (PARTITION BY YEAR(Date) ORDER BY SUM(Quantity) DESC)
    FROM FACT_TRANSACTIONS as FT join DIM_MODEL as DM on FT.IDModel = DM.IDModel
    WHERE YEAR(Date) IN (2008, 2009, 2010)
    GROUP BY YEAR(Date), Model_Name
  )
SELECT Model_Name
FROM Ranking
WHERE RN <= 5
GROUP BY Model_Name
HAVING COUNT(*) = 3





--Q7--END	
--Q8--BEGIN

WITH CTE1 AS
(
SELECT Manufacturer_name, DATEPART(Year,date) as yr,
DENSE_RANK() OVER (PARTITION BY DATEPART(Year,date) ORDER BY SUM(TotalPrice) DESC) AS Rank 
    FROM Fact_Transactions FT
    JOIN DIM_Model DM ON FT.IDModel = DM.IDModel
    JOIN DIM_MANUFACTURER MFC  ON MFC.IDManufacturer = DM.IDManufacturer
    group by Manufacturer_name,DATEPART(Year,date) 
),
CTE2 AS(
SELECT Manufacturer_Name, yr
FROM CTE1 WHERE rank = 2
AND yr IN ('2009','2010')
)
SELECT C.Manufacturer_Name AS Manufacturer_Name_2009
,T.Manufacturer_Name AS Manufacturer_Name_2010
FROM CTE2 AS C, CTE2 AS T
WHERE C.yr < T.yr;




--Q8--END
--Q9--BEGIN
	
	select *
from DIM_MANUFACTURER AS DFC
where exists (select 1
              from FACT_TRANSACTIONS AS FT join
                   DIM_MODEL DM
                   on FT.idmodel = DM.idmodel
              where DFC.IDManufacturer = DM.IDManufacturer and
                    FT.Date >= '2010-01-01' and FT.Date < '2011-01-01'
             ) and
      not exists (select 1
                  from FACT_TRANSACTIONS FT join
                       DIM_MODEL AS DM
                      on FT.idmodel = DM.idmodel
                  where DFC.IDManufacturer = DM.IDManufacturer and
                        FT.Date >= '2009-01-01' and FT.Date < '2010-01-01'
                 ) ;






--Q9--END

--Q10--BEGIN
	
	  SELECT * ,(( AVG_SALES - LAG_VALUE)/(LAG_VALUE))  AS PERC_CHANGE
    FROM (SELECT * , LAG(AVG_SALES,1) OVER(PARTITION BY CUSTOMER_NAME ORDER BY YEAR_) AS LAG_VALUE 
          FROM (SELECT DC.Customer_Name, YEAR(FT.DATE) AS YEAR_ , AVG(FT.TOTALPRICE) AS AVG_SALES , AVG(FT.QUANTITY) AS AVG_QTY
                FROM FACT_TRANSACTIONS AS FT
                JOIN DIM_CUSTOMER AS DC
                ON DC.IDCustomer=FT.IDCustomer
                WHERE FT.Quantity>0 AND DC.Customer_Name IN (SELECT  TOP 10 DC.Customer_Name
	                                                         FROM DIM_CUSTOMER AS DC
	                                                         JOIN FACT_TRANSACTIONS AS FT 
	                                                         ON DC.IDCustomer=FT.IDCustomer
	                                                         GROUP BY DC.Customer_Name
	                                                         ORDER BY SUM(FT.TOTALPRICE) DESC)
               GROUP BY DC.Customer_Name , YEAR(FT.DATE)
           ) AS TT2
      ) AS TT3	






--Q10--END
	