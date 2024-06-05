CREATE PROCEDURE [dbo].[Usp_Registersystemtenantdata]
    @JsonObjectdata NVARCHAR(MAX)
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
		IF(JSON_VALUE(@JsonObjectdata, '$.Tenantid')=0)
			BEGIN
				INSERT INTO Systemtenants(Tenantname,Tenantlogo,Emailserver,Emailpassword,Consumerkey,Shortcode,Consumersecret,Tenantstatus,Passkey,
				Validationurl,Confirmationurl,Sandboxregurl,Sandboxsimurl,Sandboxauthurl,Systemurl,Stkpushurl,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Tenantname'),JSON_VALUE(@JsonObjectdata, '$.Tenantlogo'),JSON_VALUE(@JsonObjectdata, '$.Emailserver'),JSON_VALUE(@JsonObjectdata, '$.Emailpassword'),JSON_VALUE(@JsonObjectdata, '$.Consumerkey'),JSON_VALUE(@JsonObjectdata, '$.Shortcode'),JSON_VALUE(@JsonObjectdata, '$.Consumersecret'),0,JSON_VALUE(@JsonObjectdata, '$.Tenantlipanampesapasskey'),
				'http://localhost:44396/api/v1/channelm/c2b/validate/','http://localhost:44396/api/v1/channelm/c2b/confirm/','https://sandbox.safaricom.co.ke/mpesa/c2b/v1/registerurl','https://sandbox.safaricom.co.ke/mpesa/c2b/v1/simulate',
				'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials','https://ca2c-102-68-77-46.ngrok-free.app/api/v1/channelm/expr/callback/','https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
				JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
				Set @RespMsg ='System Tenant Saved Successfully.'
				Set @RespStat =0; 
			END
		ELSE
			BEGIN
				UPDATE Systemtenants SET Tenantname=JSON_VALUE(@JsonObjectdata, '$.Tenantname'),Tenantlogo=JSON_VALUE(@JsonObjectdata, '$.Tenantlogo'),Emailserver=JSON_VALUE(@JsonObjectdata, '$.Emailserver'),Emailpassword=JSON_VALUE(@JsonObjectdata, '$.Emailpassword'),Consumerkey=JSON_VALUE(@JsonObjectdata, '$.Consumerkey'),Shortcode=JSON_VALUE(@JsonObjectdata, '$.Shortcode'),
				Consumersecret=JSON_VALUE(@JsonObjectdata, '$.Consumersecret'),Passkey=JSON_VALUE(@JsonObjectdata, '$.Tenantlipanampesapasskey'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE Tenantid=JSON_VALUE(@JsonObjectdata, '$.Tenantid')
				Set @RespMsg ='System Tenant Updated Successfully.'
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