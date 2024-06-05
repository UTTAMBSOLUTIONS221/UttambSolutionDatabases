CREATE PROCEDURE [dbo].[Usp_Getsystemdashboardcustomerdata]
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
		SELECT 
			   (SELECT COUNT(C.CustomerId) FROM CustomerAgreements CA INNER JOIN Customers C ON CA.CustomerId=C.CustomerId WHERE CA.AgreemettypeId IN (SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename='Prepaid-Agreement'))  AS Prepaidcustomer,
			   (SELECT COUNT(C.CustomerId) FROM CustomerAgreements CA INNER JOIN Customers C ON CA.CustomerId=C.CustomerId WHERE CA.AgreemettypeId IN (SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename!='Prepaid-Agreement'))  AS Postpaidcustomer
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