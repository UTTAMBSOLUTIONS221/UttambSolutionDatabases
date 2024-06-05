CREATE PROCEDURE [dbo].[Usp_Getallofflinesalesdata]
@TenantId BIGINT
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
		SELECT a.FinanceTransactionId,a.TenantId,a.TransactionCode,a.AutomationRefence,a.ActualDate,a.DateCreated,
		g.Sname AS Stationname,h.Firstname+' '+h.Lastname AS Attendantname,j.CardSNO +'-'+ j.CardCode AS CardSNO,l.EquipmentRegNo,e.Productvariationname,
		f.Paymentmode,b.AccountId,c.Units,c.Price,c.Discount,d.TotalUsed,d.TotalPaid
		FROM FinanceTransactions a 
		INNER JOIN SystemTickets b ON a.FinanceTransactionId=b.FinanceTransactionId
		INNER JOIN Ticketlines c ON b.TicketId=c.TicketId
		INNER JOIN TicketlinePayments d ON c.TicketId=d.TicketId
		INNER JOIN SystemProductvariation e ON c.ProductvariationId=e.ProductvariationId
		INNER JOIN Paymentmodes f ON d.PaymentmodeId=f.PaymentmodeId
		INNER JOIN SystemStations g ON b.StationId=g.StationId
		INNER JOIN SystemStaffs h ON b.StaffId=h.Userid
		INNER JOIN SystemAccountCards i ON b.AccountId=i.AccountId
		INNER JOIN Systemcard j ON i.CardId=j.CardId
		INNER JOIN CustomerVehicleUsages k ON b.TicketId=k.TicketId
		INNER JOIN CustomerEquipments l ON k.EquipmentId=l.EquipmentId
		WHERE a.Tenantid=@TenantId

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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