CREATE PROCEDURE [dbo].[Usp_Registermpesanotificationlogs]
    @IsTxnSuccessFull BIT,
	@Action VARCHAR(100),
	@Response VARCHAR(200),
	@DateCreated DATETIME,
    @TransactionType VARCHAR(100),
	@TransID VARCHAR(100),
	@TransTime VARCHAR(100),
	@TransAmount DECIMAL(18,2),
	@BusinessShortCode VARCHAR(100),
	@BillRefNumber VARCHAR(100),
	@InvoiceNumber VARCHAR(100),
	@OrgAccountBalance DECIMAL(18,2),
	@ThirdPartyTransId VARCHAR(100),
	@MSISDN VARCHAR(100),
	@FirstName VARCHAR(100),
	@MiddleName VARCHAR(100),
	@LastName VARCHAR(100)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		BEGIN
				INSERT INTO Mpesanotificationlogs(Action,IsTxnSuccessFull,DateCreated,TransactionType,TransID,TransTime,TransAmount,BusinessShortCode,BillRefNumber,InvoiceNumber,OrgAccountBalance,ThirdPartyTransId,MSISDN,FirstName,MiddleName,LastName,TxnErrorMsg)
				VALUES(@Action,@IsTxnSuccessFull,@DateCreated,@TransactionType,@TransID,@TransTime,@TransAmount,@BusinessShortCode,@BillRefNumber,@InvoiceNumber,@OrgAccountBalance,@ThirdPartyTransId,@MSISDN,@FirstName,@MiddleName,@LastName,@Response)
				
				Set @RespMsg ='Log Saved Successfully.'
				Set @RespStat =0; 
			END
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