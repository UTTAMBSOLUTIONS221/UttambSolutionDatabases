CREATE PROCEDURE [dbo].[Usp_Registermpesastkapiresponselog]
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
	@LastName VARCHAR(100),
	@ServiceCode int,
	@OrgRef varchar(50),
	@Receiver Varchar(50),
	@ResultCode Varchar(10),
	@ResultDescr Varchar(250),
	@TxnID Varchar(15),
	@Amount decimal(12,2)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@PaymentRef Varchar(20) = '',
			@ServiceNo varchar(20),
			@AccountNo varchar(20),
			@PAmount decimal(12,2),
			@Id int,
			@Stat int,
			@PType int,
			@PService int
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		BEGIN
		       
			   	---- Get payment
		Select	@Id = Paymentid, 
				@Stat = PStatus, 
				@PType = PType, 
				@PService = ServiceCode, 
				@PaymentRef = PaymentRef, 
				@AccountNo = Extra1,
				@PAmount = Amount 
		From Payments Where ExtRef = @OrgRef

		---- Validate Service
		If(@Stat Is Null)
		Begin
			Select 1 as RespStatus, 'Failed to trace the payment record!' as RespMessage	
			Return
		End
		If(@PType <> 3)
		Begin
			Select 1 as RespStatus, 'Operation not allowed for this type of payment!' as RespMessage	
			Return
		End
		If(@Amount <> @PAmount)
		Begin
			Select 1 as RespStatus, 'Failed due to amount mismatch!' as RespMessage	
			Return
		End

		--- Update record now
		Update Payments Set RespNo = @ResultCode, 
			RespMsg = (Case when @ResultCode = '0' Then '' Else @ResultDescr End), 
			ExtRef = @TxnID,
			PStatus =(Case when @ResultCode = '0' Then 2 Else 3 End),
			AccountName = @Receiver
		Where Paymentid = @Id

				INSERT INTO Mpesanotificationlogs(Action,IsTxnSuccessFull,DateCreated,TransactionType,TransID,TransTime,TransAmount,BusinessShortCode,BillRefNumber,InvoiceNumber,OrgAccountBalance,ThirdPartyTransId,MSISDN,FirstName,MiddleName,LastName,TxnErrorMsg)
				VALUES(@Action,@IsTxnSuccessFull,@DateCreated,@TransactionType,@TransID,@TransTime,@TransAmount,@BusinessShortCode,@BillRefNumber,@InvoiceNumber,@OrgAccountBalance,@ThirdPartyTransId,@MSISDN,@FirstName,@MiddleName,@LastName,@Response)
				

				SELECT	@RespStat as RespStatus, 
				@RespMsg as RespMessage,
				@PaymentRef as Data2,
				@ServiceNo as Data3,
				@AccountNo as Data4
				Set @RespMsg ='Log Saved Successfully.'
				Set @RespStat =0; 
			END
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage, SCOPE_IDENTITY() AS Data1, @TransID AS Data2,@TransAmount AS Data3;
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