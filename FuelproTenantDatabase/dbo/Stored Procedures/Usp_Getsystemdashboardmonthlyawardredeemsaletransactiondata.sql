CREATE PROCEDURE [dbo].[Usp_Getsystemdashboardmonthlyawardredeemsaletransactiondata]
@SalesTransactionDetailData VARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		BEGIN TRANSACTION;
		SET @SalesTransactionDetailData=(SELECT 0 AS Systemstaffs, 0 AS Prepaidcustomer,0 AS Postpaidcustomer,0 AS OnlineSales,0 AS OfflineSales,0 AS AwardedPoints,0 AS RedeemedPoints,
		(
			SELECT (SELECT ISNULL(SUM(GL.Amount),0)
			FROM GLTransactions GL
			INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId
			WHERE FT.IsOnlineSale=1 AND FT.Saledescription IN ('Sale','Reverse')) AS OnlineSales,
			(SELECT ISNULL(SUM(GL.Amount),0)
			FROM GLTransactions GL
			INNER JOIN FinanceTransactions FT ON GL.FinanceTransactionId=FT.FinanceTransactionId
			WHERE FT.IsOnlineSale=0 AND FT.Saledescription IN ('Sale','Reverse')) AS OfflineSales,
			0 AS AwardedPoints,0 AS RedeemedPoints,
			ST.Sname AS Stationname 
			FROM SystemTickets TKT 
			INNER JOIN SystemStations ST ON TKT.StationId=ST.Tenantstationid
			INNER JOIN TicketlinePayments TKP ON TKT.TicketId=TKP.TicketId 
			GROUP BY ST.Sname
			FOR JSON PATH
		) AS SalesTransactions
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER)
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@SalesTransactionDetailData AS SalesTransactionDetailData;

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