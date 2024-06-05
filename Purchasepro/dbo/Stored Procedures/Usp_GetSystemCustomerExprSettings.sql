CREATE PROCEDURE [dbo].[Usp_GetSystemCustomerExprSettings]
	@ServiceCode int
AS
BEGIN
	SET NOCOUNT ON;
	Declare @RespStat int = 0,
			@RespMsg varchar(150) = '';

    BEGIN TRY
		---- Get service details
		SELECT Stkpushurl as Data1, Sandboxauthurl as Data2,Consumerkey as Data3,Consumersecret as Data4,Passkey as Data5,Systemurl as Data6,Shortcode as Data7,Shortcode as Data8,Sandboxregurl as Data9, Validationurl as Data10, Confirmationurl as Data11 FROM SystemTenants WHERE Shortcode = @ServiceCode

		select * from SystemTenants
	END TRY
	BEGIN CATCH
		SELECT @RespMsg = ERROR_MESSAGE(), @RespStat = 2;	
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage	
	END CATCH	
END