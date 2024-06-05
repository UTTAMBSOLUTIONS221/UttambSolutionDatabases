CREATE PROCEDURE [dbo].[Usp_Replacecustomeraccountcarddata]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
	        @Accountnumber BIGINT,
			@CardId BIGINT,
			@EquipmentId BIGINT,
			@AccountId BIGINT;
			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		 IF((SELECT TagTypename FROM Systemcardtype WHERE TagtypeId=JSON_VALUE(@JsonObjectdata, '$.MaskType'))='V-Card')
		 BEGIN
			  SET @Accountnumber=NEXT VALUE FOR AccountNumberSequence;
			  INSERT INTO Systemcard
			  VALUES(@Accountnumber,CONVERT(VARCHAR(20),@Accountnumber)+'FUELPRO',JSON_VALUE(@JsonObjectdata, '$.Pin'),JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),NULL,1,0,1,0,(SELECT TOP 1 TagtypeId FROM Systemcardtype WHERE TagTypename='V-Card'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated')  AS datetime2))
		 
			 SET @CardId=SCOPE_IDENTITY();
			 UPDATE  SystemAccountCards SET CardId=@CardId, AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId') WHERE  CardId=JSON_VALUE(@JsonObjectdata, '$.CardId')

			 UPDATE Systemcard SET IsReplaced=1 WHERE CardId=JSON_VALUE(@JsonObjectdata, '$.CardId')
			 UPDATE Systemcard SET IsAssigned=1,PIN=JSON_VALUE(@JsonObjectdata, '$.Pin'),PinHarsh= JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),CardCode=dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID) WHERE CardId=@CardId
		 
			INSERT INTO ReplacedCards(OldCardid,NewCardid,Replacedby,Datecreated)
			VALUES(JSON_VALUE(@JsonObjectdata, '$.CardId'),@CardId,JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		 END
		 ELSE
		 BEGIN
		 
				UPDATE  SystemAccountCards SET CardId=JSON_VALUE(@JsonObjectdata, '$.MaskId') WHERE  CardId=JSON_VALUE(@JsonObjectdata, '$.CardId') AND AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')

				UPDATE Systemcard SET IsReplaced=1 WHERE CardId=JSON_VALUE(@JsonObjectdata, '$.CardId')

				UPDATE Systemcard SET PIN=JSON_VALUE(@JsonObjectdata, '$.Pin'),PinHarsh= JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),CardCode=dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),IsAssigned=1 WHERE CardId=JSON_VALUE(@JsonObjectdata, '$.MaskId')

				INSERT INTO ReplacedCards(OldCardid,NewCardid,Replacedby,Datecreated)
				VALUES(JSON_VALUE(@JsonObjectdata, '$.CardId'),JSON_VALUE(@JsonObjectdata, '$.MaskId'),JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

		 END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		SELECT @RespStat as RespStatus, @RespMsg as RespMessage,CASE WHEN AA.Designation='Corporate' THEN AA.Companyname ELSE AA.Firstname+' '+ AA.Lastname END AS Data1,AA.Emailaddress AS Data2,EE.CardSNO AS Data3,EE.PIN AS Data4,EE.PinHarsh AS Data5,EE.CardCode AS Data6 FROM Customers AA 
		INNER JOIN CustomerAgreements BB ON AA.CustomerId=BB.CustomerId
		INNER JOIN CustomerAccount CC ON BB.AgreementId=CC.AgreementId
		INNER JOIN SystemAccountCards DD ON CC.AccountId=DD.AccountId
		INNER JOIN Systemcard EE ON DD.CardId=EE.CardId
		WHERE EE.CardId=@CardId;


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