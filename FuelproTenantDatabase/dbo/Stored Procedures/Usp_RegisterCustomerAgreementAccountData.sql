CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountData]
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
		  VALUES(@Accountnumber,CONVERT(VARCHAR(20),@Accountnumber)+'VCARD',JSON_VALUE(@JsonObjectdata, '$.Pin'),JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),NULL,1,0,1,0,(SELECT TOP 1 TagtypeId FROM Systemcardtype WHERE TagTypename='V-Card'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))
		 
		 SET @CardId=SCOPE_IDENTITY();

		  INSERT INTO CustomerAccount(AgreementId,AccountNumber,GroupingId,ParentId,CredittypeId,LimitTypeId,ConsumptionLimit,ConsumptionPeriod,
			Isadminactive,Iscustomeractive,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.AgreementId'),
				NEXT VALUE FOR AccountNumberSequence,
				(SELECT TOP 1 GroupingId FROM CustomerAgreements WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId')),
				(SELECT TOP 1 AccountId FROM CustomerAccount WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId') AND ParentId=0),
				(SELECT TOP 1 CredittypeId FROM CustomerAccount WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId') AND ParentId=0),
				JSON_VALUE(@JsonObjectdata, '$.LimitTypeId'),
				JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimit'),
				JSON_VALUE(@JsonObjectdata, '$.ConsumptionPeriod'),
				1,1,1,0,
				JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)

				SET @AccountId=SCOPE_IDENTITY();

				INSERT INTO SystemAccountCards
				VALUES(@AccountId,@CardId)	

				UPDATE Systemcard SET IsAssigned=1,CardCode=dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID) WHERE CardId=@CardId

				SET @Accountnumber=(SELECT AccountNumber FROM CustomerAccount WHERE AccountId=@AccountId);

				INSERT INTO ChartofAccounts
				VALUES(@Accountnumber,12)
		 END
		 ELSE
		 BEGIN
		  INSERT INTO CustomerAccount(AgreementId,AccountNumber,GroupingId,ParentId,CredittypeId,LimitTypeId,ConsumptionLimit,ConsumptionPeriod,
			Isadminactive,Iscustomeractive,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.AgreementId'),
				NEXT VALUE FOR AccountNumberSequence,
				(SELECT TOP 1 GroupingId FROM CustomerAgreements WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId')),
				(SELECT TOP 1 AccountId FROM CustomerAccount WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId') AND ParentId=0),
				(SELECT TOP 1 CredittypeId FROM CustomerAccount WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId') AND ParentId=0),
				JSON_VALUE(@JsonObjectdata, '$.LimitTypeId'),
				JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimit'),
				JSON_VALUE(@JsonObjectdata, '$.ConsumptionPeriod'),
				1,1,1,0,
				JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)

				SET @AccountId=SCOPE_IDENTITY();
				INSERT INTO SystemAccountCards
				VALUES(@AccountId,JSON_VALUE(@JsonObjectdata, '$.MaskId'))	

				UPDATE Systemcard SET PIN=JSON_VALUE(@JsonObjectdata, '$.Pin'),PinHarsh= JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),CardCode=dbo.fn_ToBase36(NEXT VALUE FOR dbo.sq_PaymentTxnID),IsAssigned=1 WHERE CardId=JSON_VALUE(@JsonObjectdata, '$.MaskId')

				SET @Accountnumber=(SELECT AccountNumber FROM CustomerAccount WHERE AccountId=@AccountId);

				INSERT INTO ChartofAccounts
				VALUES(@Accountnumber,12)
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