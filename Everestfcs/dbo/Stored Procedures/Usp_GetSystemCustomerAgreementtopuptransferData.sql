CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAgreementtopuptransferData]
	@Agreementaccountid BIGINT
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
		  SELECT aa.AccountTopupId,aa.FinanceTransactionId,ee.TransactionCode,ee.Saledescription,ee.SaleRefence,aa.AccountId,aa.StationId,bb.Sname AS StationName,aa.ModeofPayment,cc.Paymentmode,aa.Topupreference,aa.Amount,aa.Erprefe,
		  aa.Chequeno,aa.Bankaccno,aa.Drawerbank,aa.Payeebank,aa.Branchdeposited,ee.Isreversed,aa.Depositslip,aa.Createdby,dd.Firstname+' '+dd.Lastname AS Fullname,aa.DateCreated
		  FROM CustomerAccountTopups aa
		  INNER JOIN SystemStations bb ON aa.StationId=bb.StationId
		  INNER JOIN Paymentmodes cc ON aa.ModeofPayment=cc.PaymentmodeId
		  INNER JOIN SystemStaffs dd ON aa.Createdby=dd.UserId
		  INNER JOIN Financetransactions ee ON aa.FinanceTransactionId=ee.FinanceTransactionId
		  WHERE aa.accountId=@Agreementaccountid

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
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