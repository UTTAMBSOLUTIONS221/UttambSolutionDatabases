CREATE PROCEDURE [dbo].[Usp_GetSystemTenantCardById]
	@Tenantcardid BIGINT
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
	        SELECT @RespStat as RespStatus, @RespMsg as RespMessage,CASE WHEN AA.Designation='Corporate' THEN AA.Companyname ELSE AA.Firstname+' '+ AA.Lastname END AS Data1,AA.Emailaddress AS Data2,EE.CardSNO AS Data3,EE.PIN AS Data4,EE.PinHarsh AS Data5,EE.CardCode AS Data6,EE.Tenantid AS Data7,EE.CardId AS Data8 FROM Customers AA 
			INNER JOIN CustomerAgreements BB ON AA.CustomerId=BB.CustomerId
			INNER JOIN CustomerAccount CC ON BB.AgreementId=CC.AgreementId
			INNER JOIN SystemAccountCards DD ON CC.AccountId=DD.AccountId
			INNER JOIN Systemcard EE ON DD.CardId=EE.CardId
			WHERE EE.CardId=@Tenantcardid;

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
