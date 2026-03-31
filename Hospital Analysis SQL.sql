---creating database
CREATE DATABASE HospitalDB;

---use hospitalDB to create tables,clean data and perform analysis
USE HospitalDB;

---creating tables
CREATE TABLE Encounters(
ID CHAR(36) PRIMARY KEY, 
START DATETIME,
STOP DATETIME,
PATIENT CHAR(36),
ORGANIZATION CHAR(36),
PAYER CHAR(36),
ENCOUNTERCLASS CHAR(20),
CODE INTEGER,
DESCRIPTION CHAR(100),
BASEENCOUNTERCOST DECIMAL(5,2),
TOTALCLAIMC0ST DECIMAL(10,2),
PAYERCOVERAGE DECIMAL(10,2),
REASONCODE VARCHAR(100),
REASONDESCRIPTION CHAR(100)
);

---create patients table
CREATE TABLE Patients(
ID CHAR(36) PRIMARY KEY,
BIRTHDATE DATE,
DEATHDATE DATE,
PREFIX VARCHAR(10),
FIRST NVARCHAR(100),
LAST NVARCHAR(100),
SUFFIX VARCHAR(10),
MAIDEN VARCHAR(100),
MARITAL CHAR(1),
RACE VARCHAR(50),
ETHNICITY VARCHAR(50),
GENDER CHAR(1),
BIRTHPLACE NVARCHAR(255),
ADDRESS NVARCHAR(255),
CITY VARCHAR(100),
STATE VARCHAR(100),
COUNTY VARCHAR(100),
ZIP VARCHAR(10),
LAT DECIMAL (20,15),
LON DECIMAL (20,15)
);

---create payers table
CREATE TABLE Payers(
 ID CHAR(36) PRIMARY KEY,
 NAME VARCHAR(100),
 ADDRESS VARCHAR(255),
 CITY VARCHAR(100),
 STATEHEADQUARTERED CHAR(2),
 ZIP VARCHAR(10),
 PHONE VARCHAR(20)
);

---create procedures table
CREATE TABLE Procedures(
START DATETIME,
STOP DATETIME,
PATIENT CHAR(36),
ENCOUNTER CHAR(36),
CODE VARCHAR(100),
DESCRIPTION VARCHAR(255),
BASECOST INTEGER,
REASONCODE VARCHAR(100),
REASONDESCRIPTION VARCHAR (255)
);

---create organization table
CREATE TABLE ORGANIZATION(
ID CHAR(36) PRIMARY KEY,
NAME CHAR(30),
ADDRESS CHAR(15),
CITY CHAR(6),
STATE CHAR(2),
ZIP INTEGER,
LAT DECIMAL(7,5),
LON DECIMAL(6,4)
);

---bulk insert data into the five tables created
BULK INSERT Encounters
FROM 'C:\Users\HP\OneDrive\Desktop\data analysis\Portfolio Work\Encounterss.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR =',',
ROWTERMINATOR = '\n'
);


BULK INSERT Patients
FROM 'C:\Users\HP\OneDrive\Desktop\data analysis\Portfolio Work\Patientss.csv'
WITH (
FIRSTROW = 2,
CODEPAGE='65001',
DATAFILETYPE='char',
FIELDTERMINATOR =',',
ROWTERMINATOR = '\n'
);


BULK INSERT Payers
FROM 'C:\Users\HP\OneDrive\Desktop\data analysis\Portfolio Work\Payerss.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR =',',
ROWTERMINATOR = '\n'
);


BULK INSERT Procedures
FROM 'C:\Users\HP\OneDrive\Desktop\data analysis\Portfolio Work\Proceduress.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR =',',
ROWTERMINATOR = '\n'
);


BULK INSERT Organization
FROM 'C:\Users\HP\OneDrive\Desktop\data analysis\Portfolio Work\Organizationss.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR =',',
ROWTERMINATOR = '\n'
);

---checking completeness of data in the five tables
SELECT COUNT(*) AS TotalRows FROM Encounters ;

SELECT COUNT(*) AS TotalRows FROM Patients;

SELECT COUNT(*) AS TotalRows FROM Payers;

SELECT COUNT(*) AS TotalRows FROM Procedures;

SELECT COUNT(*) AS TotalRows FROM Organization;

---checking for consistency
SELECT DISTINCT REASONCODE,REASONDESCRIPTION FROM Encounters;

SELECT * FROM Patients
WHERE BIRTHDATE=DEATHDATE;


---Analytical Questions

---Encounter Ovrview

---how many encounters occured each year?
SELECT YEAR(START) AS Year,COUNT(ID) AS TotalEncounters FROM Encounters
GROUP BY YEAR(START)
ORDER BY YEAR(START) ASC;

---For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgent care, emergency, and inpatient)?
WITH YearlyEncounters AS (SELECT YEAR(START) AS Year,COUNT(ID) AS YearlyTotal
FROM Encounters
GROUP BY YEAR(START))

SELECT YEAR(START) AS Year,
ENCOUNTERCLASS AS EncounterClass,
COUNT(ID) AS TotalEncounters,
ROUND((CAST(COUNT(ID) AS FLOAT)/YearlyTotal) * 100,2) AS Percentage
FROM Encounters,YearlyEncounters
WHERE YEAR(START)=YearlyEncounters.Year
GROUP BY Year(START), ENCOUNTERCLASS,YearlyEncounters.YearlyTotal
ORDER BY YEAR(START) ASC,TotalEncounters ASC;

-- c. What percentage of encounters were over 24 hours versus under 24 hours?

WITH TimePeriod AS (SELECT START,STOP, DATEDIFF(HOUR,START,STOP) AS Duration
FROM Encounters)

SELECT 
START,
STOP,
CASE
WHEN Duration<=24 THEN 'Under24Hours' 
WHEN Duration>24 THEN 'Over24Hours' 
END AS DurationCategory
FROM TimePeriod;

---How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
SELECT COUNT(PAYERCOVERAGE) AS TotalZeroPayerCoverage
FROM Encounters
WHERE PAYERCOVERAGE=0;


SELECT ENCOUNTERCLASS,DESCRIPTION,
CASE
WHEN PAYERCOVERAGE= 0 THEN 'ZeroCoverage'
WHEN PAYERCOVERAGE >0 THEN 'PayerCoverage'
END AS PayerCoverageCategory
FROM Encounters;

---Cost and Coverage Insights

--- what are the top 10 most frequent procedures performed and the average base cost for each?
SELECT TOP 10 DESCRIPTION,COUNT(DESCRIPTION) AS Frequency,AVG(BASECOST) AS AvgBaseCost
FROM Procedures
GROUP BY DESCRIPTION
ORDER BY Frequency DESC;

---what are the top 10 procedures with the highest average base cost and the number of times they were performed?
SELECT TOP 10 DESCRIPTION,COUNT(DESCRIPTION) AS Frequency,AVG(BASECOST) AS AvgBaseCost
FROM Procedures
GROUP BY DESCRIPTION
ORDER BY AVG(BASECOST) DESC;

---what is the average total claim cost for encounters, broken down by payer?
SELECT p.NAME, AVG(TOTALCLAIMC0ST) AS AvgTotalClaimCost
FROM Payers p
INNER JOIN Encounters e
ON e.PAYER = p.ID
GROUP BY p.NAME
ORDER BY AvgTotalClaimCost ASC;

---Patient Behaviour Analysis

---how many unique patients were admitted each quarter over time?
SELECT 
YEAR(START) AS Year,
DATEPART(QUARTER,START) AS Quarter,
COUNT(DISTINCT PATIENT) AS UniquePatients
FROM Encounters
GROUP BY YEAR(START),DATEPART(QUARTER,START)
ORDER BY Year,Quarter;

---how many patients were readmitted within 30 days of a previous encounter?
SELECT 
COUNT(DISTINCT e1.PATIENT) AS ReadmittedPatients
FROM Encounters e1
INNER JOIN Encounters e2
ON e1.PATIENT=e2.PATIENT
AND e2.START>e1.STOP
AND DATEDIFF(DAY,e1.STOP,e2.START) <=30
AND e1.ID <> e2.ID;

---which patients had the most readmissions?

SELECT
e1.PATIENT,
p.FIRST,
p.LAST,
    COUNT(DISTINCT e2.ID) AS Readmissions
FROM Encounters e1
INNER JOIN Encounters e2
    ON e1.PATIENT = e2.PATIENT
    AND e2.START > e1.STOP
    AND DATEDIFF(DAY, e1.STOP, e2.START) <= 30
    AND e1.ID != e2.ID
INNER JOIN Patients p
    ON e1.PATIENT = p.Id
GROUP BY p.FIRST, p.LAST,e1.PATIENT
ORDER BY Readmissions DESC;