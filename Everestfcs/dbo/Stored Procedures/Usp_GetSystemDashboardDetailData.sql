
CREATE PROCEDURE [dbo].[Usp_GetSystemDashboardDetailData]
    @StationId BIGINT,
	@TenantId BIGINT,
	@TodayDate DATETIME,
	@DashboardDetailsData NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;	
			SET @DashboardDetailsData=(SELECT 
			(SELECT (SELECT COUNT(a.UserId) FROM Systemstaffs a INNER JOIN LnkStaffStation b ON a.Userid=b.UserId WHERE a.Tenantid=@TenantId AND  (b.StationId=@StationId OR 0=@StationId)) AS Systemstaffs,
			(SELECT COUNT(C.CustomerId) FROM CustomerAgreements CA INNER JOIN Customers C ON CA.CustomerId=C.CustomerId 
			WHERE C.Tenantid =@TenantId AND (C.StationId=@StationId OR 0=@StationId) AND CA.AgreemettypeId IN (SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename='Prepaid-Agreement'))  AS Prepaidcustomer,
			(SELECT COUNT(C.CustomerId) FROM CustomerAgreements CA INNER JOIN Customers C ON CA.CustomerId=C.CustomerId 
			WHERE C.Tenantid =@TenantId AND (C.StationId=@StationId OR 0=@StationId) AND CA.AgreemettypeId IN (SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename!='Prepaid-Agreement'))   AS Postpaidcustomer,
			(SELECT COUNT(ISNULL(GL.GLTransactionId,0))
			FROM GLTransactions GL
			INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId
			WHERE FT.IsOnlineSale=1 AND FT.Tenantid=@TenantId  AND FT.DateCreated BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, 1, @TodayDate)) AND DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AND FT.Saledescription IN ('Sale','Reverse')) AS OnlineSales,
			(SELECT COUNT(ISNULL(GL.GLTransactionId,0))
			FROM GLTransactions GL
			INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId
			WHERE FT.IsOnlineSale=0  AND FT.Tenantid=@TenantId AND FT.DateCreated BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, 1, @TodayDate)) AND DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AND FT.Saledescription IN ('Sale','Reverse')) AS OfflineSales,
			0 AS AwardedPoints,
			0 AS RedeemedPoints,
			(SELECT SS.Sname AS StationName,ISNULL(SUM(CASE WHEN FT.IsOnlineSale = 1 THEN GL.Amount ELSE 0 END), 0) AS OnlineSaleAmount,ISNULL(SUM(CASE WHEN FT.IsOnlineSale = 0 THEN GL.Amount ELSE 0 END), 0) AS OfflineSaleAmount
			FROM  GLTransactions GL
				INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId = FT.FinanceTransactionId
				INNER JOIN SystemTickets ST ON ST.FinanceTransactionId = FT.FinanceTransactionId
				INNER JOIN SystemStations SS ON ST.StationId = SS.StationId
			WHERE FT.Tenantid = @TenantId AND FT.DateCreated >= DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AND FT.DateCreated < DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate) + 1, 0) AND FT.Saledescription IN ('Sale', 'Reverse')
			GROUP BY SS.Sname FOR JSON PATH) AS DailySales,
       (SELECT SS.Sname AS StationName,ISNULL(SUM(CASE WHEN FT.IsOnlineSale = 1 THEN GL.Amount ELSE 0 END), 0) AS OnlineSaleAmount,ISNULL(SUM(CASE WHEN FT.IsOnlineSale = 0 THEN GL.Amount ELSE 0 END), 0) AS OfflineSaleAmount
		FROM  GLTransactions GL
			INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId = FT.FinanceTransactionId
			INNER JOIN SystemTickets ST ON ST.FinanceTransactionId = FT.FinanceTransactionId
			INNER JOIN SystemStations SS ON ST.StationId = SS.StationId
		WHERE FT.Tenantid = @TenantId AND FT.DateCreated >=DATEADD(DAY, 1 - DAY(@TodayDate), CAST(DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AS DATETIME))  
				AND FT.DateCreated < DATEADD(DAY, 1, DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @TodayDate) + 1, 0))) AND FT.Saledescription IN ('Sale', 'Reverse')
			GROUP BY SS.Sname FOR JSON PATH) AS MonthlySales,
			(SELECT SS.Sname AS StationName,
			ISNULL(SUM(CASE WHEN  LT.LTransactionTypeName='Award' THEN LR.RewardAmount ELSE 0 END), 0) AS PointAwardAmount,
			ISNULL(SUM(CASE WHEN  LT.LTransactionTypeName='Redeem' THEN LR.RewardAmount ELSE 0 END), 0) AS PointRedeemAmount
			FROM LRResults LR
            INNER JOIN LRADataInputs LRA ON LR.LRADataInputId=LRA.LRADataInputId
            INNER JOIN FinanceTransactions FT ON LRA.FinanceTransactionId=FT.FinanceTransactionId
            INNER JOIN  LtransactionTypes LT ON LT.LTransactionTypeId=LR.LTransactionTypeId
			INNER JOIN SystemTickets ST ON ST.FinanceTransactionId = FT.FinanceTransactionId
			INNER JOIN SystemStations SS ON ST.StationId = SS.StationId
			WHERE LR.LRewardId=(SELECT LRewardId FROM LRewards LR WHERE LR.RewardName='Points') AND FT.Tenantid = @TenantId AND FT.DateCreated >= DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AND FT.DateCreated < DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate) + 1, 0) AND FT.Saledescription IN ('Sale', 'Reverse')
			GROUP BY SS.Sname FOR JSON PATH) AS DailyAwards,
			(SELECT SS.Sname AS StationName,
			ISNULL(SUM(CASE WHEN  LT.LTransactionTypeName='Award' THEN LR.RewardAmount ELSE 0 END), 0) AS PointAwardAmount,
			ISNULL(SUM(CASE WHEN  LT.LTransactionTypeName='Redeem' THEN LR.RewardAmount ELSE 0 END), 0) AS PointRedeemAmount
			FROM LRResults LR
            INNER JOIN LRADataInputs LRA ON LR.LRADataInputId=LRA.LRADataInputId
            INNER JOIN FinanceTransactions FT ON LRA.FinanceTransactionId=FT.FinanceTransactionId
            INNER JOIN  LtransactionTypes LT ON LT.LTransactionTypeId=LR.LTransactionTypeId
			INNER JOIN SystemTickets ST ON ST.FinanceTransactionId = FT.FinanceTransactionId
			INNER JOIN SystemStations SS ON ST.StationId = SS.StationId
			WHERE LR.LRewardId=(SELECT LRewardId FROM LRewards LR WHERE LR.RewardName='Points') AND FT.Tenantid = @TenantId AND FT.DateCreated >=DATEADD(DAY, 1 - DAY(@TodayDate), CAST(DATEADD(DAY, DATEDIFF(DAY, 0, @TodayDate), 0) AS DATETIME))  
				AND FT.DateCreated < DATEADD(DAY, 1, DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, @TodayDate) + 1, 0))) AND FT.Saledescription IN ('Sale', 'Reverse')
			GROUP BY SS.Sname FOR JSON PATH) AS MonthlyAwards
			 FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
			 ) AS Dashboarddata);
	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@DashboardDetailsData as DashboardDetailsData;

		END TRY
		BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ''
		PRINT 'Error ' + error_message();
		Select 2 as RespStatus, '0 - Error(s) Occurred' + error_message() as RespMessage
		END CATCH
		Select @RespStat as RespStatus, @RespMsg as RespMessage;
		RETURN; 
		END;
	END
END