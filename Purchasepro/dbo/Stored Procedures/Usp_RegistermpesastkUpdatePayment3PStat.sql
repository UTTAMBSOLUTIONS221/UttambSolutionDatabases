CREATE PROCEDURE Usp_RegistermpesastkUpdatePayment3PStat
	@RefNo varchar(20),
	@Stat int,
	@Msg varchar(150)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @PaymentRef varchar(15),
			@RespStat int = 0,
			@RespMsg varchar(150) = ''

    BEGIN TRY
		---- Validate 
		--If Not Exists(Select Id  From Payments Where PaymentRef = @RefNo)
		--Begin
		--	Select 1 as RespStatus, 'Invalid payment!' as RespMessage	
		--	Return
		--End

		--Update Payments Set TPStat = @Stat, TPMessage = @Msg Where PaymentRef = @RefNo

		--- Create response
		SELECT @RespStat as RespStatus, @RespMsg as RespMessage

	END TRY
	BEGIN CATCH
		SELECT @RespMsg = ERROR_MESSAGE(), @RespStat = 2;	
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage	
	END CATCH	
END