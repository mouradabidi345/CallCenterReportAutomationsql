

--Inbound Calls Metric
DECLARE @direction AS NVARCHAR(20) = 'Inbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type AS NVARCHAR(20) = 'Phone Call'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE

---STEP 1 = GET THE BASE 

--USES A CARTESIAN PRODUCT TO ENSRE WE INCLUDE ALL POSSIBLE COMBINATIONS OF WEEK AND AGENT

TRUNCATE TABLE WFM_TEMP.week_at_a_glance

INSERT INTO WFM_TEMP.week_at_a_glance
(
InContactID
, [Name]
, [Supervisor]
,[Week]
,[Period]
)

SELECT
    [InContactID]
      ,[Name]
      ,[Supervisor]
      ,W.[WEEK]
	  ,[Period]
--INTO #AGENT_BASE   
FROM [dbo].[Agent_Base] AB
  CROSS JOIN WEEKS W


/******  INBOUND CALLS  ******/

SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B.[Direction]
  , B.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(B.[Contact_ID])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS
FROM AGENT_BASE A
JOIN #BASE B
  ON B.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B.Direction = @direction
  AND B.Media_Type_Name = @media_type
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B.[Direction]
  , B.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [Inbound_Calls] = X.[INBOUND CALLS]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C.[Name]
  , C.Supervisor
  , C.[InContactID]
  , C.[Week_Number] [Week]
  , C.[Period]
  , C.[Count]/2 [Inbound Calls]
--INTO #FINAL
FROM #CALL_COUNTS C
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]




----------------------------------------------------------------------------------------------------------------------------------------------------------
--Outbound Calls Metric-------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @direction1 AS NVARCHAR(20) = 'Outbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type1 AS NVARCHAR(20) = 'Phone Call'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE

/******  OUtbound CALLS  ******/

SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE1
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B1.[Direction]
  , B1.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(B1.[Contact_ID])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS1
FROM AGENT_BASE A
JOIN #BASE1 B1
  ON B1.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B1.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B1.Direction = @direction1
  AND B1.Media_Type_Name = @media_type1
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B1.[Direction]
  , B1.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE TABLE AGAIN HERE
UPDATE WFM_TEMP.week_at_a_glance
  SET [Outbound_Calls] = X.[Outbound_Calls]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN

(
SELECT
    C1.[Name]
  , C1.Supervisor
  , C1.[InContactID]
  , C1.[Week_Number] [Week]
  , C1.[Period]
  , C1.[Count]/2 [Outbound_Calls]
--INTO #FINAL1
FROM #CALL_COUNTS1 C1
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]

 
 ---------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --Inound E-Mails Metric

DECLARE @direction2 AS NVARCHAR(20) = 'Inbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type2 AS NVARCHAR(20) = 'E-Mail'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE



SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE2
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B2.[Direction]
  , B2.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(B2.[Contact_ID])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS2
FROM AGENT_BASE A
JOIN #BASE2 B2
  ON B2.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B2.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B2.Direction = @direction2
  AND B2.Media_Type_Name = @media_type2
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B2.[Direction]
  , B2.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [Inbound_Emails] = X.[Inbound E-mails]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C2.[Name]
  , C2.Supervisor
  , C2.[InContactID]
  , C2.[Week_Number] [Week]
  , C2.[Period]
  , C2.[Count]/2 [Inbound E-mails]
--INTO #FINAL
FROM #CALL_COUNTS2 C2
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]




---------------------------------------------------------------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------------------------------------------------------------------
  --Outbound E-Mails Metric
  
DECLARE @direction3 AS NVARCHAR(20) = 'Outbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type3 AS NVARCHAR(20) = 'E-Mail'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE



SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE3
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B3.[Direction]
  , B3.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(B3.[Contact_ID])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS3
FROM AGENT_BASE A
JOIN #BASE3 B3
  ON B3.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B3.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B3.Direction = @direction3
  AND B3.Media_Type_Name = @media_type3
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B3.[Direction]
  , B3.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [Outbound_EMails] = X.[Outbound E-Mails]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C3.[Name]
  , C3.Supervisor
  , C3.[InContactID]
  , C3.[Week_Number] [Week]
  , C3.[Period]
  , C3.[Count]/2 [Outbound E-Mails]
--INTO #FINAL
FROM #CALL_COUNTS3 C3
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]



	-----------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------
--Average Handle Time Inbound Calls
DECLARE @direction4 AS NVARCHAR(20) = 'Inbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type4 AS NVARCHAR(20) = 'Phone Call'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE
SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  , RDS.Handle_Time
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE4
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B4.[Direction]
  , B4.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Average_Handle_Time] = AVG(B4.[Handle_Time])/60
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_Handle_time
FROM AGENT_BASE A
JOIN #BASE4 B4
  ON B4.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B4.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B4.Direction = @direction4
  AND B4.Media_Type_Name = @media_type4
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B4.[Direction]
  , B4.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [AHT_Inbound_Calls] = X.[AHT Inbound Calls]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C4.[Name]
  , C4.Supervisor
  , C4.[InContactID]
  , C4.[Week_Number] [Week]
  , C4.[Period]
  , C4.[Average_Handle_Time] [AHT Inbound Calls]
--INTO #FINAL
FROM #CALL_Handle_time C4
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Average Handle Time Outbound Calls
DECLARE @direction5 AS NVARCHAR(20) = 'Outbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type5 AS NVARCHAR(20) = 'Phone Call'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE
SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  , RDS.Handle_Time
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE5
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B5.[Direction]
  , B5.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Average_Handle_Time] = AVG(B5.[Handle_Time])/60
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_Handle_time1
FROM AGENT_BASE A
JOIN #BASE5 B5
  ON B5.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B5.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B5.Direction = @direction5
  AND B5.Media_Type_Name = @media_type5
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B5.[Direction]
  , B5.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [AHT_Outbound_Calls] = X.[AHT Outbound Calls]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C5.[Name]
  , C5.Supervisor
  , C5.[InContactID]
  , C5.[Week_Number] [Week]
  , C5.[Period]
  , C5.[Average_Handle_Time] [AHT Outbound Calls]
--INTO #FINAL
FROM #CALL_Handle_time1 C5
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Average Handle Time Inbound E-Mail
DECLARE @direction6 AS NVARCHAR(20) = 'Inbound'; -- THIS VARIABLE CAN BE CHANGED TO 'OUTBOUND'
DECLARE @media_type6 AS NVARCHAR(20) = 'E-Mail'; -- THIS WOULD BE ANY OF THE VARIOUS MEDIA TYPES AVAILABLE
SELECT
    RDS.[Report_Start_Date]
  , RDS.[Agent_Name]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , RDS.[Team_Name]
  , RDS.[Contact_ID]
  , CAST(RDS.[CONTACT_START_DATE_TIME] AS DATE) AS [Contact_Start_Date]
  , CONVERT(VARCHAR(8), RDS.[CONTACT_START_DATE_TIME], 108) AS [Date_Time]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  , RDS.Handle_Time
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RDS.[REFUSALS], 0) AS Refusals
  --, ISNULL(RDS.[HOLD_TIME], '00:00:00') AS [Hold_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE6
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B6.[Direction]
  , B6.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Average_Handle_Time] = AVG(B6.[Handle_Time])/60
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_Handle_time2
FROM AGENT_BASE A
JOIN #BASE6 B6
  ON B6.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B6.Contact_Start_Date BETWEEN W.[FROM] AND W.[TO]
WHERE B6.Direction = @direction6
  AND B6.Media_Type_Name = @media_type6
GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B6.[Direction]
  , B6.[Media_Type_Name]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

--UPDATE INBOUND CALLS COLUMN OF WFM_TEMP.week_at_a_glance

UPDATE WFM_TEMP.week_at_a_glance
  SET [AHT_Inbound_EMails] = X.[AHT Inbound E-Mails]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    C6.[Name]
  , C6.Supervisor
  , C6.[InContactID]
  , C6.[Week_Number] [Week]
  , C6.[Period]
  , C6.[Average_Handle_Time] [AHT Inbound E-Mails]
--INTO #FINAL
FROM #CALL_Handle_time2 C6
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]




-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--AVERAGE HOLD TIME
SELECT
    RH.[Report_Start_Date]
  , RH.[Agent_Name]
  , RH.[Direction]
  , RH.[Media_Type_Name]
  , RH.[Contact_ID]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RH.[Hold_Time], 0) AS [Hold_Time]
  , ISNULL(RH.[Holds], 0) AS [Holds]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE7
FROM [dbo].[Raw_Data_Hold_Time] RH

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B7.[Direction]
  , B7.[Media_Type_Name]
  ,B7.[Hold_Time]
  ,B7.Holds
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Actual_hold_time] = B7.[Hold_Time]/B7.Holds
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #Actual_hold_time
FROM AGENT_BASE A
JOIN #BASE7 B7
  ON B7.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B7.[Report_Start_Date] BETWEEN W.[FROM] AND W.[TO]

GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B7.[Direction]
  , B7.[Media_Type_Name]
  ,B7.[Hold_Time]
  ,B7.Holds
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]


select AH.[Name]
  , AH.Supervisor
  , AH.[InContactID]
  ,AH.[Week_Number]
  , AH.Period
  ,[Average_Hold_Time] = AVG(AH.[Actual_hold_time])/60

into #Average_Hold_Time
from #Actual_hold_time AH

GROUP BY AH.[Name]
  , AH.Supervisor
  , AH.[InContactID]
  ,AH.[Week_Number]
  , AH.Period
  
UPDATE WFM_TEMP.week_at_a_glance
  SET [Average_Hold_Time] = X.[Average_Hold_Time]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(
SELECT
    AHT.[Name]
  , AHT.Supervisor
  , AHT.[InContactID]
  , AHT.[Week_Number] [Week]
  , AHT.[Period]
  , AHT.[Average_Hold_Time] [Average_Hold_Time]
--INTO #FINAL
FROM #Average_Hold_Time AHT

) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]



-------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Count of Hold time above 2 minutes
  SELECT
    RH.[Report_Start_Date]
  , RH.[Agent_Name]
  , RH.[Direction]
  , RH.[Media_Type_Name]
  , RH.[Contact_ID]
  --, ISNULL(RDS.[ACW_TIME], '00:00:00') AS [ACW_Time]
  --, ISNULL(RDS.[HANDLE_TIME], '00:00:00') AS [Handle_Time]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HANDLE_TIME]), 0) AS [Handle_Time_Seconds]
  , ISNULL(RH.[Hold_Time], 0) AS [Hold_Time]
  , ISNULL(RH.[Holds], 0) AS [Holds]
  --, ISNULL(DATEDIFF(second, 0, RDS.[HOLD_TIME]), 0) AS [Hold_Time_Seconds]
INTO #BASE8
FROM [dbo].[Raw_Data_Hold_Time] RH

----==========================
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B8.[Direction]
  , B8.[Media_Type_Name]
  ,B8.[Hold_Time]
  ,B8.Holds
  --, B.[Contact_Start_Date]
  , W.[Week] [Week_Number]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Actual_hold_time] = B8.[Hold_Time]/B8.Holds
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #Actual_hold_time1
FROM AGENT_BASE A
JOIN #BASE8 B8
  ON B8.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON B8.[Report_Start_Date] BETWEEN W.[FROM] AND W.[TO]

GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  , B8.[Direction]
  , B8.[Media_Type_Name]
  ,B8.[Hold_Time]
  ,B8.Holds
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]


select AH1.[Name]
  , AH1.Supervisor
  , AH1.[InContactID]
  ,AH1.[Week_Number]
  , AH1.Period
  ,[Count_Hold_Time>2] = count(AH1.[Actual_hold_time])

into #Count_Hold_Time
from #Actual_hold_time1 AH1
where AH1.[Actual_hold_time]>120
GROUP BY AH1.[Name]
  , AH1.Supervisor
  , AH1.[InContactID]
  ,AH1.[Week_Number]
  , AH1.Period


UPDATE WFM_TEMP.week_at_a_glance
  SET [Count_Hold_Time_GT_2] = X.[Count_Hold_Time>2]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

SELECT
    CHT.[Name]
  , CHT.Supervisor
  , CHT.[InContactID]
  , CHT.[Week_Number] [Week]
  , CHT.[Period]
  , CHT.[Count_Hold_Time>2] [Count_Hold_Time>2]
--INTO #FINAL
FROM #Count_Hold_Time CHT
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]

----------------------------------------------------------------------------------------------------------------------------  
----------------------------------------------------------------------------------------------------------------------------
--Refusals

SELECT 
    RDS.[Report_Start_Date]
  , A.[Name]
  , A.[InContactID]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , A.[Supervisor]
  , W.[Week]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , COUNT(RDS.[Refusals]) AS [Refusal_Count]
INTO #BASE9
FROM [dbo].[CXONE_Supervisor_Snapshot] RDS
JOIN dbo.[WEEKS] W
  ON CAST(RDS.[Contact_Start_Date_Time] AS DATE) BETWEEN W.[FROM] AND W.[TO]
LEFT JOIN dbo.[Agent_Base] A
  ON A.[Name] = RDS.Agent_Name
WHERE A.[Supervisor] IS NOT NULL
GROUP BY
    RDS.[Report_Start_Date]
  , A.[Name]
  , A.[InContactID]
  , RDS.[Direction]
  , RDS.[Media_Type_Name]
  , A.[Supervisor]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
ORDER BY
    [Name]
  , [Period]


SELECT
    B9.[Name]
  , B9.Supervisor
  , B9.[InContactID]
  , B9.[Week]
  , B9.[Period]
  , ISNULL(SUM(B9.[Refusal_Count]), 0) [Refusal_Count]
into #Refusal
FROM #BASE9 B9

GROUP BY
    B9.[Name]
  , B9.Supervisor
  , B9.[InContactID]
  , B9.[Week]
  , B9.[Period]


UPDATE WFM_TEMP.week_at_a_glance
  SET [Refusals] = X.[Refusals]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

SELECT
    RE.[Name]
  , RE.Supervisor
  , RE.[InContactID]
  , RE.[Week]
  , RE.[Period]
  , RE.[Refusal_Count]/2 [Refusals]
--INTO #FINAL
FROM #Refusal RE
) X 
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------	
--
--AVG ACW

SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [Average] = AVG(ACW.[ACW_Time])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS4
FROM AGENT_BASE A
JOIN ACW_Actual ACW
  ON ACW.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON ACW.Date BETWEEN W.[FROM] AND W.[TO]

GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

UPDATE WFM_TEMP.week_at_a_glance
  SET [Average_ACW] = X.[Average ACW]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

SELECT
    C4.[Name]
  , C4.Supervisor
  , C4.[InContactID]
  , C4.[Week]
  , C4.[Period]
  , C4.[Average] [Average ACW]
FROM #CALL_COUNTS4 C4
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
--ACW>5
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(ACW.[ACW_Time])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS5
FROM AGENT_BASE A
JOIN ACW_Actual ACW
  ON ACW.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON ACW.Date BETWEEN W.[FROM] AND W.[TO]
WHERE ACW.ACW_Time > 5

GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

UPDATE WFM_TEMP.week_at_a_glance
  SET [ACW_GT_5] = X.[ACW>5]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(


SELECT
    C5.[Name]
  , C5.Supervisor
  , C5.[InContactID]
  , C5.[Week]
  , C5.[Period]
  , C5.[count]/2 [ACW>5]
FROM #CALL_COUNTS5 C5
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]



	-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------------------------------------------

--ACW>10
SELECT
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , [Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  , [COUNT] = COUNT(ACW.[ACW_Time])
  --, W.[FROM] Week_Start_Date
  --, W.[TO] Week_End_Date
  --, DATEADD(DAY, 8 - DATEPART(WEEKDAY, B.CONTACT_START_DATE), CAST(B.CONTACT_START_DATE AS DATE)) [Week_End_Date]
  --, B.Handle_Time_Seconds
INTO #CALL_COUNTS6
FROM AGENT_BASE A
JOIN ACW_Actual ACW
  ON ACW.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON ACW.Date BETWEEN W.[FROM] AND W.[TO]
WHERE ACW.ACW_Time > 10

GROUP BY
    A.[Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]
----==========================

UPDATE WFM_TEMP.week_at_a_glance
  SET [ACW_GT_10] = X.[ACW>10]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

SELECT
    C6.[Name]
  , C6.Supervisor
  , C6.[InContactID]
  , C6.[Week]
  , C6.[Period]
  , C6.[count]/2 [ACW>10]
FROM #CALL_COUNTS6 C6
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Adherence

SELECT Adhe.[Agent]
       ,A.[Supervisor] 
      ,Adhe.[IncontactId]
	  ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(Adhe.[InAdherence]) [SumInAdherence]
	  ,Sum(Adhe.[OutofAdherence]) [SumOutofAdherence] 

  INTO #Adherence
  FROM AGENT_BASE A
  JOIN [dbo].[Raw_Data_Adherance] Adhe
  ON Adhe.[Agent] = A.[NAME]
  JOIN dbo.[WEEKS] W
  ON Adhe.[Timstamp]  BETWEEN W.[FROM] AND W.[TO]

GROUP BY  Adhe.[Agent]
       ,A.[Supervisor] 
      ,Adhe.[IncontactId]
	  ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      


select ACE.[Agent]
       ,ACE.[Supervisor] 
      ,ACE.[IncontactId]
	  ,ACE.[Week]
      ,ACE.[Period]
	  ,ACE.[SumInAdherence]
	  ,ACE.[SumOutofAdherence]
	  ,[Total] = ACE.[SumInAdherence] + ACE.[SumOutofAdherence]
	  --,[Average] = ACE.[SumInAdherence]/(Sum(ACE.[SumInAdherence] + ACE.[SumOutofAdherence]))

into #AdherenceFinal1
from  #Adherence ACE

--where [Week] = '6/2021'
Group By ACE.[Agent]
       ,ACE.[Supervisor] 
      ,ACE.[IncontactId]
	  ,ACE.[Week]
      ,ACE.[Period]
	  ,ACE.[SumInAdherence]
	  ,ACE.[SumOutofAdherence]



select A1.[Agent]
       ,A1.[Supervisor] 
      ,A1.[IncontactId]
	  ,A1.[Week]
     ,A1.[Period]
	  ,A1.[SumInAdherence]
	  ,A1.[SumOutofAdherence]
	  ,A1.[Total]
	  ,[Average] = ROUND(convert(VARCHAR(50), (CAST(A1.[SumInAdherence] AS FLOAT)/CAST(A1.[Total] AS FLOAT))*100), 2)

Into #AdherenceFinal2 
from #AdherenceFinal1 A1
--where [Week] = '4/2021'

group by A1.[Agent]
       ,A1.[Supervisor] 
      ,A1.[IncontactId]
	  ,A1.[Week]
      ,A1.[Period]
	  ,A1.[SumInAdherence]
	  ,A1.[SumOutofAdherence]
	  ,A1.[Total]


UPDATE WFM_TEMP.week_at_a_glance
  SET [Adherence] = X.[Adherence]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(


select F2.[Agent]
       ,F2.[Supervisor] 
      ,F2.[IncontactId]
	  ,F2.[Week]
      ,F2.[Period]
	  ,F2.[Average] [Adherence]


from #AdherenceFinal2 F2
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]


-----------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
--Total hours Worked
SELECT
    H.[Agent_Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , [Period] = CAST(CONVERT(VARCHAR
  , W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
  -- [COUNT] = Sum(H.[Login_Time])
  ,[Total Hours in seconds] = SUM(DATEDIFF(SECOND, '0:00:00', H.[Login_Time]))/2
  --, [Total Hours] = CONVERT(time(7), SUM(DATEDIFF(SECOND, '0:00:00', H.[Login_Time])), 108)

INTO #HoursWorked
FROM AGENT_BASE A
JOIN [dbo].[Total_Hours] H
  ON H.Agent_Name = A.[NAME]
JOIN dbo.[WEEKS] W
  ON H.Date BETWEEN W.[FROM] AND W.[TO]


GROUP BY
    H.[Agent_Name]
  , A.[Supervisor]
  , A.[InContactID]
  --, B.[Contact_Start_Date]
  , W.[Week]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 
--ORDER BY [NAME], [WEEK_END_DATE]


select  [Agent_Name]
      ,[Supervisor]
      , [InContactID]
  --, B.[Contact_Start_Date]
  , [Week]
  , [Period]
   --,[Total Hours in seconds]
   ,[Total hours Worked] = RIGHT('0' + CAST([Total Hours in seconds] / 3600 AS VARCHAR),2) + ':' +
                   RIGHT('0' + CAST(([Total Hours in seconds] / 60) % 60 AS VARCHAR),2) + ':' +
                    RIGHT('0' + CAST([Total Hours in seconds] % 60 AS VARCHAR),2)

into #FinalHoursWorked
from #HoursWorked

UPDATE WFM_TEMP.week_at_a_glance
  SET [Total_hours_Worked] = X.[Total hours Worked]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(


select  FW.[Agent_Name]
        ,FW.[Supervisor]
         ,FW.[InContactID]
       , FW.[Week]
        , FW.[Period]
        ,FW.[Total hours Worked]

from #FinalHoursWorked FW
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]




----	-------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--INSERT INTO [dbo].week_at_a_glance
--            ([Name],
--            [Supervisor]
--            ,[InContactID]
--            ,[Inbound Calls]
--             ,[Week]
--                      ,[Outbound_Calls])


--SELECT      F.[Name],
--             F.[Supervisor]
--            ,F.[InContactID]
--            ,F.[Inbound Calls]
--            ,F.[Week]
--                      ,F1.[Outbound_Calls]
      

--FROM #FINAL F Inner join #FINAL1 F1
--ON F.[InContactID] = F1.[InContactID] AND
--   F.[Week] = F1.[Week] 




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ADP hours:
SELECT ADP.[Full Name]
      ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(ADP.[Hours]) [TotalHours]
       

  INTO #TotalHours
  from  [dbo].[Raw_Data_Total_Paid_Hours] ADP
  JOIN dbo.[WEEKS] W
  ON ADP.[Report_Start_Date]  BETWEEN W.[FROM] AND W.[TO]

GROUP BY  ADP.[Full Name]
      ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      
--------------------------------------------------------------

SELECT ADP.[Full Name]
     ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(ADP.[Hours]) [PaidTimeOffHours]
         

  INTO #PaidTimeOff
from  [dbo].[Raw_Data_Total_Paid_Hours] ADP
  JOIN dbo.[WEEKS] W
  ON ADP.[Report_Start_Date]  BETWEEN W.[FROM] AND W.[TO]


where ADP.[Description] = 'Paid Time Off'
GROUP BY  ADP.[Full Name]
     ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      
-------------------------------------------------------------------------------------

SELECT ADP.[Full Name]
      ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(ADP.[Hours]) [FMLAHours]
         

  INTO #FMLA
  from  [dbo].[Raw_Data_Total_Paid_Hours] ADP
  JOIN dbo.[WEEKS] W
  ON ADP.[Report_Start_Date]  BETWEEN W.[FROM] AND W.[TO]


where ADP.[Description] = 'FMLA'
GROUP BY  ADP.[Full Name]
      ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      
------------------------------------------------------------------------------------------------------

SELECT ADP.[Full Name]
      ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(ADP.[Hours]) [UnPaidTimeOffHours]
         

  INTO #UnPaidTimeOff
  from  [dbo].[Raw_Data_Total_Paid_Hours] ADP
  JOIN dbo.[WEEKS] W
  ON ADP.[Report_Start_Date]  BETWEEN W.[FROM] AND W.[TO]


where ADP.[Description] = 'UnPaid Time Off'
GROUP BY  ADP.[Full Name]
      ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      

-------------------------------------------------------------------------------------------------------------------------------------------------


SELECT ADP.[Full Name]
      ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      ,Sum(ADP.[Hours]) [HolidayHours]
         

  INTO #Holiday
from  [dbo].[Raw_Data_Total_Paid_Hours] ADP
  JOIN dbo.[WEEKS] W
  ON ADP.[Report_Start_Date]  BETWEEN W.[FROM] AND W.[TO]


where ADP.[Description] = 'Holiday'
GROUP BY  ADP.[Full Name]
      ,W.[Week]
      ,CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
      


select  th.*
        , p.[PaidTimeOffHours]
              ,f.FMLAHours
              ,U.UnPaidTimeOffHours
              ,H.HolidayHours

INTO #tOTAL

from #TotalHours th
LEFT join #PaidTimeOff p
ON TH.[Full Name] = P.[Full Name]
AND TH.[Week] = P.[Week]
LEFT join #FMLA f
ON F.[Full Name] = TH.[Full Name]
AND TH.[Week] = F.[Week]
LEFT join #UnPaidTimeOff u
ON u.[Full Name] = TH.[Full Name]
AND TH.[Week] = u.[Week]
LEFT join #Holiday h
ON H.[Full Name] = th.[Full Name]
AND TH.[Week] = H.[Week]



SELECT  Total.[Full Name]
        ,Total.[Week]
              , Total.[Period]
              ,[ADP Hours] = ISNULL(Total.TotalHours, 0) - (ISNULL(Total.[PaidTimeOffHours], 0) + ISNULL(Total.[FMLAHours], 0) + ISNULL(Total.[UnPaidTimeOffHours], 0) + ISNULL(Total.[HolidayHours], 0))

              ---- somehow it is showing that [ADP Hours] is a string and not a decimal

into  #lastTable
FROM #tOTAL Total





UPDATE #lastTable
SET [Full Name]='Abreu, Manny'
WHERE [Full Name]= 'Abreu, Manuel'


UPDATE #lastTable
SET [Full Name]='Johnson, Madi'
WHERE [Full Name]= 'Johnson, Madisen'

UPDATE #lastTable
SET [Full Name]= 'Qiu, James'
WHERE [Full Name]= 'Qiu, Ziyuan'

UPDATE #lastTable
SET [Full Name]= 'Venoza, Samantha'
WHERE [Full Name]= 'Venoza, Sariah'



UPDATE #lastTable
SET [Full Name]= 'Samuels, Rachel'
WHERE [Full Name]= 'Christensen, Rachel'



SELECT L.[Full Name]
       ,L.[Week]
          ,L.[Period]
          ,L.[ADP Hours]
        ,A.[InContactID]
              ,[dECIMAL] = CAST((L.[ADP Hours]/2) as DECIMAL(17,2))   ---- this is to  convert [ADP Hours] to decimal 


into #Lasttable1
FROM #lastTable L
inner join AGENT_BASE A
  ON L.[Full Name] = A.[NAME]


select  l1.[Full Name]
         ,l1.[Week]
		 ,l1.[Period]
		 --,l1.[ADP Hours]
		 ,l1.InContactID
       , Cast(parseName([Decimal],2) as nvarchar) + ':' + Cast(Format((((parseName([Decimal],1)) * 60)/100),'0#') as nvarchar) [Paid Hours]

into #Lasttable2
from #Lasttable1 l1
--WHERE [wEEK] = '15/2021'


/*select L2.[Full Name]
         ,L2.[Week]
		 ,L2.[Period]
		 --,l1.[ADP Hours]
		 ,L2.InContactID
       , [Paid Hours] = cast(L2.[Paid Hour] AS time)


into #lasttable3
from #Lasttable2 L2*/

UPDATE WFM_TEMP.week_at_a_glance
  SET [Paid_Hours]= X.[Paid Hours]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(


select  distinct [Full Name]
        --,L2.[Supervisor]
         ,L2.[InContactID]
       , L2.[Week]
        , L2.[Period]
        ,L2.[Paid Hours]

from #Lasttable2 L2
) X
  ON WG.INCONTACTID = X.INCONTACTID
    AND WG.[WEEK] = X.[WEEK]


	------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
--Occurences:

DECLARE @DUP_COUNT INT
DECLARE @DUP_COUNT1 INT
DECLARE @Week nvarchar(10)

DECLARE @Results table ([inContact_ID] bigint, 
						[Name] nvarchar(Max),
						[Count] int,
						[Period] nvarchar(Max),
						[Week] nvarchar(10))


SET @DUP_COUNT = (
SELECT COUNT(1)
FROM [dbo].[Weeks]
)



select [Week]
,[From]
into #Week
from [dbo].[Weeks]
order by [From] asc


WHILE @DUP_COUNT > 0
BEGIN


Set @Week = (
select TOP(1) [Week]
from #Week
order by [From] ASC
)


declare @time varchar(max)
set @time = @Week


declare @Period varchar(max)
set @Period = (select distinct [Period]

 

from dbo.Weeks
where [Week] = @time)


declare @Weekend  date
set @Weekend = (select distinct [To]

 

from dbo.Weeks
where [Week] = @time)

 


declare @last60days date
set @last60days = (select DATEADD(day, -60, @Weekend))

 


Insert INTO @Results
([inContact_ID] , [Name] , [Count] , [Week] , [Period])
SELECT distinct Occ.[inContact_ID]
      ,A.[Name]
      
         ,[Count] = count(Occ.[Reason Code])/2
		 , @time
	     , @Period
from  [dbo].[Raw_Data_Attendance_Calendar] Occ
  inner join Agent_Base A
  on A.InContactID = Occ.inContact_ID
  JOIN dbo.[WEEKS] W
  ON Occ.[Occurrence Date]  BETWEEN W.[FROM] AND W.[TO]

 

where Occ.[Occurrence Date] > @last60days
GROUP BY  Occ.[inContact_ID]
       , A.[Name]
     



Delete From #Week
Where [Week] = @Week

SET @DUP_COUNT = @DUP_COUNT - 1



END

/*Select R.inContact_ID
       ,R.[Name]
	   ,R.[Count] [Occurences]
	   ,R.[Period]
	   ,R.[Week]

From @Results R

order by [Week]
	   , [inContact_ID]*/

UPDATE WFM_TEMP.week_at_a_glance
  SET [Occurences] = X.[Occurences]

--SELECT WG.*
--  , X.[INBOUND CALLS]

FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

Select R.[Name]
	   ,R.inContact_ID
	    ,R.[Week]
	   ,R.[Period]
	   ,R.[Count] [Occurences]



From @Results R
) X
  ON WG.INCONTACTID = X.inContact_ID
    AND WG.[WEEK] = X.[WEEK]



--	=======================================================================
--Login_Percentage
select  W.InContactID,
        W.Report_Start_Date
		,W.Workeddays
		,K.[WorkedDays] AS [Value]
	   ,A.[Name]
	   ,A.[Supervisor] 
	 

into #Login
from [dbo].[Workeddays] W

inner join [dbo].[KbAttendance] K
on W.[InContactID] = K.[InContactID]
AND W.[Report_Start_Date] = K.[WeekStartDate]

join AGENT_BASE A 
on A.InContactID = W.[InContactID]



select L.*
       ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))

into #login1
from #Login L
JOIN dbo.[WEEKS] W
 ON L.Report_Start_Date  BETWEEN W.[FROM] AND W.[TO]

select L1.*
       ,CASE 
	       WHEN L1.[Value] = 0
		   THEN NULL
		   ELSE L1.[Workeddays]/L1.[Value]
       END AS [Insight_Login]
	  

into #Login2
from #login1 L1




select L2.*
      ,CASE 
	     WHEN L2.[Insight_Login] > 1 THEN '100%'
		 WHEN L2.[Insight_Login] = 1 THEN '100%'
		 WHEN  L2.[Insight_Login] < 1 THEN FORMAT(L2.[Insight_Login], 'P') 
      END AS [Login_Percentage]

into #login3
from #Login2 L2



UPDATE WFM_TEMP.week_at_a_glance
  SET [Login_Percentage] = X.[Login_Percentage]


FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

select distinct L3.[Name]
       , l3.[Supervisor]
	   ,l3.InContactID
	   ,l3.[Week]
	   ,l3.[Period]
	   ,l3.[Login_Percentage] [Login_Percentage]


from #login3 L3
) X
  ON WG.INCONTACTID = X.InContactID
    AND WG.[WEEK] = X.[WEEK]



--	================================================================================================================================================
--Read_Articles
select distinct R.[InContactID]
       ,A.[Name]
	   ,A.[Supervisor] 
      ,R.[Report_Start_Date]
       ,R.[Sum] [Read_Articles]
	   ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))

into #Read
from [dbo].[Read_Articles] R
join AGENT_BASE A 
on A.InContactID = R.InContactID
JOIN dbo.[WEEKS] W
 ON R.Report_Start_Date  BETWEEN W.[FROM] AND W.[TO]


UPDATE WFM_TEMP.week_at_a_glance
  SET [Read_Articles] = X.[Read_Articles]


FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

select R.[Name]
        ,R.[Supervisor]
		,R.[InContactID]
		,R.[Week]
		,R.[Period]
		,R.[Read_Articles] [Read_Articles]

from #Read R
)X
  ON WG.INCONTACTID = X.InContactID
    AND WG.[WEEK] = X.[WEEK]




	----==========================================================================================================================================
----	================================================================================================================================================
--[Total_Articles_Viewed]
select distinct V.[InContactID]
       ,A.[Name]
	   ,A.[Supervisor] 
      ,V.[Report_Start_Date]
       ,V.[TotalViewed] [Total_Articles_Viewed]
	   ,W.[Week]
      ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))

into #Viewed
from [dbo].[Viewed] V
join AGENT_BASE A 
on A.InContactID = V.InContactID
JOIN dbo.[WEEKS] W
 ON V.Report_Start_Date  BETWEEN W.[FROM] AND W.[TO]



UPDATE WFM_TEMP.week_at_a_glance
  SET [Total_Articles_Viewed] = X.[Total_Articles_Viewed]


FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(


select  V.[Name]
        ,V.[Supervisor]
		,V.[InContactID]
		,V.[Week]
		,V.[Period]
		,V.[Total_Articles_Viewed] [Total_Articles_Viewed]

from #Viewed V
)X
  ON WG.INCONTACTID = X.InContactID
    AND WG.[WEEK] = X.[WEEK]




	----==========================================================================================================================================
----	================================================================================================================================================
--[Average_QA_Overall]
SELECT QA.[Last Name, First Name] [Name]
     ,A.[Supervisor]
      , A.[InContactID]
      ,QA.[Period] [Week]
	  ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
	  ,[Average_QA_Overall] = round(AVG(QA.[Overall]),2)
into #QAOverall
  FROM [dbo].[Raw_Data_QAScores] QA
  join AGENT_BASE A
  on A.[Name] = QA.[Last Name, First Name]
  JOIN dbo.[WEEKS] W
  ON W.[Week] = QA.[Period]
--where QA.[Period] = '20/2021'
GROUP BY
    QA.[Last Name, First Name]
  , A.[Supervisor]
  , A.[InContactID]
  , QA.[Period]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))


UPDATE WFM_TEMP.week_at_a_glance
  SET [Average_QA_Overall] = X.[Average_QA_Overall]


FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

select Q.[Name]
     ,Q.[Supervisor]
      , Q.[InContactID]
      ,Q.[Week]
	  ,Q.[Period]
	  ,Q.[Average_QA_Overall] [Average_QA_Overall]
from #QAOverall Q
)X
  ON WG.INCONTACTID = X.InContactID
    AND WG.[WEEK] = X.[WEEK]


	----==========================================================================================================================================
----	================================================================================================================================================
--[Average_QA_Connectedness]
SELECT QA.[Last Name, First Name] [Name]
      ,A.[Supervisor]
      , A.[InContactID]
      ,QA.[Period] [Week]
	  ,[Period] = CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10))
	  ,[Average_QA_Connectedness] = round(AVG(QA.[Connectedness]),2)
into #QAConnectedness

  FROM [dbo].[Raw_Data_QAScores] QA
  join AGENT_BASE A
  on A.[Name] = QA.[Last Name, First Name]
  JOIN dbo.[WEEKS] W
  ON W.[Week] = QA.[Period]
--where QA.[Period] = '20/2021'
GROUP BY
    QA.[Last Name, First Name]
  , A.[Supervisor]
  , A.[InContactID]
  , QA.[Period]
  , CAST(CONVERT(VARCHAR, W.[FROM], 101) AS NVARCHAR(10)) + ' - ' + CAST(CONVERT(VARCHAR, W.[TO], 101) AS NVARCHAR(10)) 


UPDATE WFM_TEMP.week_at_a_glance
  SET [Average_QA_Connectedness] = X.[Average_QA_Connectedness]


FROM WFM_TEMP.week_at_a_glance WG
  INNER JOIN
(

select Q.[Name]
      ,Q.[Supervisor]
      ,Q.[InContactID]
      ,Q.[Week]
	  ,Q.[Period]
	  ,Q.[Average_QA_Connectedness] Average_QA_Connectedness

from #QAConnectedness Q
)X
  ON WG.INCONTACTID = X.InContactID
    AND WG.[WEEK] = X.[WEEK]





DROP TABLE #BASE
DROP TABLE #BASE1
DROP TABLE #BASE2
DROP TABLE #BASE3
DROP TABLE #BASE4
DROP TABLE #BASE5
DROP TABLE #BASE6
DROP TABLE #BASE7
drop table #BASE8
DROP TABLE #BASE9
DROP TABLE #CALL_COUNTS
DROP TABLE #CALL_COUNTS1
DROP TABLE #CALL_COUNTS2
DROP TABLE #CALL_COUNTS3
DROP TABLE #CALL_COUNTS4
DROP TABLE #CALL_COUNTS5
DROP TABLE #CALL_COUNTS6
DROP TABLE #CALL_Handle_time
DROP TABLE #CALL_Handle_time1
DROP TABLE #CALL_Handle_time2
DROP TABLE #Actual_hold_time
drop table #Actual_hold_time1
DROP TABLE #Average_Hold_Time
drop table #Count_Hold_Time
drop table #Refusal
DROP TABLE #AdherenceFinal1
drop table #AdherenceFinal2
drop table #Adherence
drop table #HoursWorked
drop table #FinalHoursWorked
drop table #TotalHours
drop table #PaidTimeOff
drop table #FMLA
drop table #UnPaidTimeOff
drop table #Holiday
DROP TABLE #tOTAL
DROP TABLE  #lastTable
DROP TABLE  #lastTable1
Drop table #Lasttable2
drop table #Week
drop table #Login
drop table #login1
drop table #Login2
drop table #login3
drop table #Read
drop table #Viewed
drop table #QAOverall
drop table #QAConnectedness





