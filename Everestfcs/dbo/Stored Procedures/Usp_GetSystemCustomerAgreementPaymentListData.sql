CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerAgreementPaymentListData]
	@AgreementId BIGINT
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
	     SELECT  a.CustomerPaymentId,a.AgreementId,a.PaymentModeId,a.FinanceTransactionId,b.TransactionCode,b.SaleRefence,b.ActualDate,a.Amount,
		 a.TransactionReference,b.Saledescription,b.Isreversed,a.TransactionDate,a.IsPaymentValidated,a.ChequeNo,a.ChequeDate,a.Memo,a.DrawerBank,a.DepositBank,a.Isactive,a.Isdeleted,
		 d.Firstname+' '+ d.Lastname AS PaidBy,a.SlipReference,a.Provider,c.Firstname+' '+ c.Lastname AS CreatedBy,a.DateCreated
		FROM CustomerPayments a 
		INNER JOIN FinanceTransactions b ON a.financetransactionId=b.FinancetransactionId
		INNER JOIN SystemStaffs c ON a.CreatedBy = c.UserId
		INNER JOIN SystemStaffs d ON a.PaidBy = d.UserId
		WHERE a.AgreementId=@AgreementId

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
