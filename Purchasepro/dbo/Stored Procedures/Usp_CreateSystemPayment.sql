CREATE PROCEDURE [dbo].[Usp_CreateSystemPayment]
	@ServiceCode int,
	@AccountNo Varchar(20),
	@AccountName Varchar(55),
	@Amount decimal(18,2),
	@PType int,
	@PStat int,
	@TPRef Varchar(25),
	@ExtRef varchar(25),
	@Extra1 Varchar(100),
	@Extra2 Varchar(100),
	@Extra3 Varchar(100),
	@Extra4 Varchar(100),
	@TPMsg Varchar(150),
    @TPStat int
AS
BEGIN
	SET NOCOUNT ON;
    Declare @PaymentRef varchar(15),
			@RespStat int = 0,
			@RespMsg varchar(150) = '',
			@ServiceType int,			
			@Data1 varchar(250) = '',
			@Data2 varchar(250) = '',
			@Data3 varchar(250) = '',
			@Data4 varchar(250) = ''

    BEGIN TRY
		-- Validate 
		If Not Exists(Select Id From PaymentStatus Where StatusCode = @PStat)
		Begin
			Select 1 as RespStatus, 'Invalid payment status!' as RespMessage	
			Return
		End

		--- Generate transaction code
		Select @PaymentRef = dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID)
		
		--- Insert data to account table
		Insert Into Payments(ServiceCode,PaymentRef,AccountNo,AccountName,Amount,PDate,PType,PStatus,TPRef,Extra1,Extra2,Extra3,Extra4,ExtRef,TPStat,TPMessage)
		Values(@ServiceCode,@PaymentRef,@AccountNo,@AccountName,@Amount,GETDATE(),@PType,@PStat,@TPRef,@Extra1,@Extra2,@Extra3,@Extra4,@ExtRef,@TPStat,@TPMsg)
		--- Create response
		SELECT	@RespStat as RespStatus, @RespMsg as RespMessage, @PaymentRef as Data1
	END TRY
	BEGIN CATCH
		SELECT @RespMsg = ERROR_MESSAGE(), @RespStat = 2;	
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage	
	END CATCH	
END