CREATE PROCEDURE [dbo].[Usp_Payloaninvoiceitemdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @Insertedfinancetransactionlid BIGINT,
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
		VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Payment',JSON_VALUE(@JsonObjectdata, '$.Paymentmemo'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2));
		IF(SCOPE_IDENTITY()<0)
		BEGIN
			return;
		END
		ELSE
		BEGIN 
			SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
		END

		INSERT INTO Systemloanitempayments(FinanceTransactionId,AccountId,Loandetailitemid,Paymentamount,Recievedamount,ModeofPayment,Paymentmemo,Topupreference,Createdby,Datecreated)
		SELECT @Insertedfinancetransactionlid,JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.Loandetailitemid'),JSON_VALUE(@JsonObjectdata, '$.Paymentamount'),
		JSON_VALUE(@JsonObjectdata, '$.Recievedamount'),'Mpesa',JSON_VALUE(@JsonObjectdata, '$.Paymentmemo'),JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2)

		INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
		VALUES (@Insertedfinancetransactionlid,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(10),JSON_VALUE(@JsonObjectdata, '$.AccountNumber'))),JSON_VALUE(@JsonObjectdata, '$.Recievedamount'),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2));
		
		IF(JSON_VALUE(@JsonObjectdata, '$.Recievedamount')=JSON_VALUE(@JsonObjectdata, '$.Paymentamount'))
		BEGIN
		  UPDATE Systemloandetailitems SET Paymentstatus =0,Payementreason='Fully Paid' WHERE Loandetailitemid=JSON_VALUE(@JsonObjectdata, '$.Loandetailitemid')
		END
		ELSE 
		BEGIN
		  UPDATE Systemloandetailitems SET Paymentstatus =1,Payementreason='Partially Paid' WHERE Loandetailitemid=JSON_VALUE(@JsonObjectdata, '$.Loandetailitemid')
		END

		Set @RespMsg ='Payment Recieved.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage;
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