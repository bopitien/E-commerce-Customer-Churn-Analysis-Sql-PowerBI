SELECT DISTINCT CityTiergroup FROM cust


---DATA CLEANING---

--check for duplicates--




SELECT CustomerID, COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY CustomerID
HAVING COUNT(CustomerID) > 1   -- no duplicates---

---- check for null ---

SELECT 
    (SELECT COUNT(*) FROM cust WHERE CustomerID IS NULL) AS 'Null_CustomerID',
    (SELECT COUNT(*) FROM cust WHERE Churn IS NULL) AS 'Null_Churn',
    (SELECT COUNT(*) FROM cust WHERE Tenure IS NULL) AS 'Null_Tenure',
    (SELECT COUNT(*) FROM cust WHERE PreferredLoginDevice IS NULL) AS 'Null_PreferredLoginDevice',
    (SELECT COUNT(*) FROM cust WHERE CityTier IS NULL) AS 'Null_CityTier',
    (SELECT COUNT(*) FROM cust WHERE WarehouseToHome IS NULL) AS 'Null_WarehouseToHome',
    (SELECT COUNT(*) FROM cust WHERE PreferredPaymentMode IS NULL) AS 'Null_PreferredPaymentMode',
    (SELECT COUNT(*) FROM cust WHERE Gender IS NULL) AS 'Null_Gender',
    (SELECT COUNT(*) FROM cust WHERE HourSpendOnApp IS NULL) AS 'Null_HourSpendOnApp',
    (SELECT COUNT(*) FROM cust WHERE NumberOfDeviceRegistered IS NULL) AS 'Null_NumberOfDeviceRegistered',
    (SELECT COUNT(*) FROM cust WHERE PreferedOrderCat IS NULL) AS 'Null_PreferedOrderCat',
    (SELECT COUNT(*) FROM cust WHERE SatisfactionScore IS NULL) AS 'Null_SatisfactionScore',
    (SELECT COUNT(*) FROM cust WHERE MaritalStatus IS NULL) AS 'Null_MaritalStatus',
    (SELECT COUNT(*) FROM cust WHERE NumberOfAddress IS NULL) AS 'Null_NumberOfAddress',
    (SELECT COUNT(*) FROM cust WHERE Complain IS NULL) AS 'Null_Complain',
    (SELECT COUNT(*) FROM cust WHERE OrderAmountHikeFromlastYear IS NULL) AS 'Null_OrderAmountHikeFromlastYear',
    (SELECT COUNT(*) FROM cust WHERE CouponUsed IS NULL) AS 'Null_CouponUsed',
    (SELECT COUNT(*) FROM cust WHERE OrderCount IS NULL) AS 'Null_OrderCount',
    (SELECT COUNT(*) FROM cust WHERE DaySinceLastOrder IS NULL) AS 'Null_DaySinceLastOrder',
    (SELECT COUNT(*) FROM cust WHERE CashbackAmount IS NULL) AS 'Null_CashbackAmount';

--- fill with the mean----
UPDATE cust
SET Tenure = (SELECT AVG(Tenure) FROM cust)
WHERE Tenure IS NULL

UPDATE cust
SET Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM cust)
WHERE Hourspendonapp IS NULL 


UPDATE cust
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM cust)
WHERE orderamounthikefromlastyear IS NULL 

UPDATE cust
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM cust)
WHERE WarehouseToHome IS NULL 

UPDATE cust
SET couponused = (SELECT AVG(couponused) FROM cust)
WHERE couponused IS NULL 

UPDATE cust
SET ordercount = (SELECT AVG(ordercount) FROM cust)
WHERE ordercount IS NULL 

UPDATE cust
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM cust)
WHERE daysincelastorder IS NULL 

----create categories column for complain and churn

ALTER TABLE cust
ADD complainstatus VARCHAR(50)

UPDATE cust
SET complainstatus =
						CASE
							WHEN Complain = 0 THEN 'No Complain'
							ELSE 'Complain'
						END



ALTER TABLE cust
ADD churnstatus VARCHAR(50)


UPDATE cust
SET churnstatus =
						CASE
							WHEN Churn = 0 THEN 'Stayed'
							ELSE 'Churned'
						END




ALTER TABLE cust
ADD citytiergroup VARCHAR(50)

UPDATE cust
SET citytiergroup =
						CASE
							WHEN CityTier = 3 THEN 'Rural Areas'
							WHEN CityTier = 2 THEN 'Urban Areas'
							ELSE 'Metropolitan Areas'
						END

--------correcting values within dataset ---------

SELECT DISTINCT PreferredLoginDevice FROM cust

UPDATE cust
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone' 


SELECT DISTINCT PreferredPaymentMode FROM cust

UPDATE cust
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC' 

UPDATE cust
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD' 


SELECT DISTINCT PreferedOrderCat FROM cust

UPDATE cust
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile' 

-------- drop outlier------

SELECT DISTINCT warehousetohome
FROM cust


DELETE FROM cust 
WHERE warehousetohome > 125 


-----EXPLORATORY DATA ANALYSIS----

----1. General Demographics----


---TOTAL CUSTOMERS

SELECT DISTINCT COUNT(CustomerID) as Totalcustomers
FROM cust   -- totalof 5628---


---What is the average tenure of your customers?--

SELECT ROUND(AVG(tenure),2) as average_tenure
FROM cust


---What is the distribution of the preferred login devices, city tiers, preferred payment modes, genders, and marital statuses of your customers?---

SELECT gender,COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY gender  -- more male customersthan female


SELECT MaritalStatus,COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY MaritalStatus  ----more married customers , then single and then divorced


SELECT PreferredPaymentMode,COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY PreferredPaymentMode  ----they mostly prefer debit card and credit card payment


SELECT PreferredLoginDevice,COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY PreferredLoginDevice  ----more prefer mobile phone logins than computer


SELECT citytiergroup ,COUNT(CustomerID) as Totalcustomers
FROM cust
GROUP BY citytiergroup   ----have more customers from metropolitan areas , followed by rural areas



---2. Churn-specific ----

-- calculate total churn and churn rate

--- total churn----
SELECT SUM(churn) as numberofchurn
FROM cust

SELECT COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%

-----or we can use a cte ---

WITH churnrate AS (SELECT COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned	
FROM cust)

SELECT numberofcustomers, totalchurned	,(ROUND((totalchurned / numberofcustomers ),4) * 100) AS churn_rate
FROM churnrate



---4. Behavioral analysis related to churn--

--Is there a correlation between the hours spent on the app and the churn rate?

UPDATE cust
SET HourSpendOnApp = CAST((HourSpendOnApp) as DECIMAL)

--difference between churned and customers who stayed according to avg hour spend on app

SELECT churnstatus, COUNT(*) AS total_customers, CAST(AVG(hourspendonapp)AS DECIMAL) as Avgtimespentonapp 
FROM cust
GROUP BY churnstatus

--churn rate by hour spent on app 

WITH hourchurn AS (SELECT  hourspendonapp, COUNT(customerid) as TOTALnumberofcustomers, 
	SUM(churn) as totalchurned	
FROM cust
GROUP BY hourspendonapp
)

SELECT hourspendonapp,TOTALnumberofcustomers,totalchurned, (ROUND((totalchurned / TOTALnumberofcustomers ),4) * 100) AS churn_rate
FROM hourchurn
ORDER BY totalchurned DESC

---Is there a correlation between the number of devices registered and the churn rate?---


SELECT numberofdeviceregistered, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%
GROUP BY numberofdeviceregistered
ORDER BY churn_rate DESC


--Does the churn rate increase when a customer has a complaint?---


SELECT complainstatus, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%
GROUP BY complainstatus
ORDER BY churn_rate DESC

---Does churn vary depending on the preferred order category?----

SELECT PreferedOrderCat, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%
GROUP BY PreferedOrderCat
ORDER BY churn_rate DESC

---Do customers who've had an order amount hike from last year have a higher churn rate?--

UPDATE cust
SET OrderAmountHikeFromlastYear = CAST((OrderAmountHikeFromlastYear) as DECIMAL)

ALTER TABLE cust
ADD OrderAmountHikestatus VARCHAR(50)

UPDATE  cust
SET OrderAmountHikestatus =  CASE
        WHEN OrderAmountHikeFromlastYear BETWEEN 0 AND 10 THEN '0-10%'
        WHEN OrderAmountHikeFromlastYear BETWEEN 11 AND 20 THEN '11-20%'
        WHEN OrderAmountHikeFromlastYear BETWEEN 21 AND 30 THEN '21-30%'
        WHEN OrderAmountHikeFromlastYear > 30 THEN '>30%'
        ELSE 'Unknown'
    END
									
SELECT OrderAmountHikestatus, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%
GROUP BY OrderAmountHikestatus
ORDER BY churn_rate DESC

---Is there a relationship between the number of coupons used and the churn rate?--

UPDATE cust
SET CouponUsed = CAST((CouponUsed) as DECIMAL)

ALTER TABLE cust
ADD CouponUsedCategory VARCHAR(50)

UPDATE  cust
SET CouponUsedCategory =  CASE
        WHEN CouponUsed = 0 THEN 'No Coupons Used'
        WHEN CouponUsed BETWEEN 1 AND 3 THEN 'Low Usage'
        WHEN CouponUsed BETWEEN 4 AND 6 THEN 'Medium Usage'
        WHEN CouponUsed >= 7 THEN 'High Usage'
        ELSE 'Unknown'
    END


SELECT CouponUsedCategory, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust --- CHURN RATE IS 16.85%
GROUP BY CouponUsedCategory
ORDER BY churn_rate DESC



-----Do customers who place orders more frequently churn at a lower rate?----

ALTER TABLE cust
ADD Ordercountgroup VARCHAR(50)

UPDATE  cust
SET Ordercountgroup =  CASE
        WHEN Ordercount BETWEEN 0 AND 10 THEN '0-10'
        WHEN Ordercount BETWEEN 11 AND 20 THEN '11-20'  
        ELSE '>20'
    END
									
SELECT Ordercountgroup, COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY Ordercountgroup
ORDER BY churn_rate DESC





----Is there a correlation between the cashback amount and the churn rate?----

ALTER TABLE cust
ADD CashbackCategory VARCHAR(50)

UPDATE cust
			SET CashbackCategory = 
				CASE
					WHEN CashbackAmount = 0 THEN 'No Cashback'
					WHEN CashbackAmount BETWEEN 1 AND 50.99 THEN 'Minimal Cashback'
					WHEN CashbackAmount BETWEEN 51 AND 150.99 THEN 'Moderate Cashback'
					WHEN CashbackAmount BETWEEN 151 AND 250.99 THEN 'Significant Cashback'
					WHEN CashbackAmount >= 251 THEN 'High Cashback'
					ELSE 'Unknown'
				END 

SELECT CashbackCategory,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY CashbackCategory
ORDER BY churn_rate DESC

  
 --5. Demographic analysis:

--Does churn vary based on gender or marital status?


SELECT Gender,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY Gender
ORDER BY churn_rate DESC


SELECT MaritalStatus,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY MaritalStatus
ORDER BY churn_rate DESC





----Does churn vary based on city tier (which might be a proxy for income level or lifestyle)?

SELECT citytiergroup,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY citytiergroup
ORDER BY churn_rate DESC


---6. Operational factors:

----Does the distance from the warehouse to home impact the churn rate?---



ALTER TABLE cust
ADD DistanceCategory VARCHAR(50) 

UPDATE cust 
SET DistanceCategory =  CASE
        WHEN WarehouseToHome < 10 THEN 'Short Distance'
        WHEN WarehouseToHome BETWEEN 10 AND 30 THEN 'Medium Distance'
        ELSE 'Long Distance'
    END 


SELECT DistanceCategory,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY DistanceCategory
ORDER BY churn_rate DESC



----Does churn vary depending on the preferred payment mode?----

SELECT preferredpaymentmode,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY preferredpaymentmode
ORDER BY churn_rate DESC



----Does the number of addresses (possibly indicating relocating or multiple residences) affect churn?----


ALTER TABLE cust
ADD AddressCategory VARCHAR(50) 

UPDATE cust 
SET AddressCategory = CASE
        WHEN NumberOfAddress = 1 THEN 'Single Address (1)'
        WHEN NumberOfAddress BETWEEN 2 AND 5 THEN 'Few Addresses (2-5)'
        WHEN NumberOfAddress BETWEEN 6 AND 10 THEN 'Several Addresses (6-10)'
        ELSE 'Many Addresses (11-20)'
    END
    

SELECT AddressCategory,COUNT(customerid) as numberofcustomers, 
	SUM(churn) as totalchurned,	
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust ---
GROUP BY AddressCategory
ORDER BY churn_rate DESC





---KPI 

--churn rate--

SELECT 
	(ROUND((SUM(churn) / COUNT(customerid) ),4) * 100) as churn_rate
FROM cust 

--Average Customer Tenure--


SELECT 
	ROUND(AVG(Tenure),0) as avg_tenure
FROM cust 


---Average Satisfaction Score----

SELECT 
	AVG(SatisfactionScore) as avg_SatisfactionScore
FROM cust 

-----Complaint Rate---

SELECT
	SUM(Complain) as complaints,	
	(ROUND((SUM(Complain) / COUNT(customerid) ),4) * 100) as complain_rate
FROM cust ---














