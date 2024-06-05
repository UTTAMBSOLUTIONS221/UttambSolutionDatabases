CREATE PROCEDURE [dbo].[Usp_UpateB2CPayment] 
	@TxnRef varchar(20),
	@Stat int,
	@Msg varchar(150),
	@NewRef varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @RespStat int = 0,
			@RespMsg varchar(150) = ''

    BEGIN TRY
		---- Validate 
		--If Not Exists(Select Id From PaymentStatus Where StatusCode = @Stat)
		--Begin
		--	Select 1 as RespStatus, 'Invalid payment status!' as RespMessage	
		--	Return
		--End
		--If Not Exists(Select Id From Payments Where PaymentRef = @TxnRef and PStatus = 0)
		--Begin
		--	Select 1 as RespStatus, 'Invalid payment!' as RespMessage	
		--	Return
		--End

		---- Update
		Update Payments Set PStatus = @Stat, RespMsg = @Msg, ExtRef = @NewRef Where PaymentRef = @TxnRef and PStatus = 0

		--- Create response
		SELECT	@RespStat as RespStatus,@RespMsg as RespMessage

	END TRY
	BEGIN CATCH
		SELECT @RespMsg = ERROR_MESSAGE(), @RespStat = 2;	
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage	
	END CATCH	
END