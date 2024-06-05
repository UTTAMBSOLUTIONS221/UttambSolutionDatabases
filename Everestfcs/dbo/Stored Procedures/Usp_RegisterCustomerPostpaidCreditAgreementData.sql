CREATE PROCEDURE [dbo].[Usp_RegisterCustomerPostpaidCreditAgreementData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE  
			@AgreementId BIGINT,
			@AccountId BIGINT,
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF((SELECT JSON_VALUE(@JsonObjectdata, '$.AgreementId'))>0)
		BEGIN
		 UPDATE CustomerAgreements SET 
		 GroupingId=JSON_VALUE(@JsonObjectdata, '$.GroupingId'),
		 PriceListId=JSON_VALUE(@JsonObjectdata, '$.PriceListId'),
		 DiscountListId=JSON_VALUE(@JsonObjectdata, '$.DiscountListId'),
		 Descriptions=JSON_VALUE(@JsonObjectdata, '$.AgreementReference'),
		 Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		 Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)
		 WHERE AgreementId= JSON_VALUE(@JsonObjectdata, '$.AgreementId')
		 UPDATE CreditAgreements SET CreditLimit=JSON_VALUE(@JsonObjectdata, '$.LimitValue'),Paymentterms=JSON_VALUE(@JsonObjectdata, '$.PaymentTerms') WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId');
		 UPDATE CreditInvoices SET DueDate=DATEADD(DAY,CAST(JSON_VALUE(@JsonObjectdata, '$.PaymentTerms') AS BIGINT),TransactionDate) WHERE CreditAgreementId=( SELECT CreditAgreementId FROM CreditAgreements WHERE AgreementId=JSON_VALUE(@JsonObjectdata, '$.AgreementId'))
		END
		ELSE
		BEGIN
		    INSERT INTO CustomerAgreements(CustomerId,GroupingId,AgreemettypeId,PriceListId,DiscountListId,BillingBasis,Descriptions,AgreementDoc,Notes,Hasgroup,HasOverdraft,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.CustomerId'),
				JSON_VALUE(@JsonObjectdata, '$.GroupingId'),
				(SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename='Credit-Agreement'),
				JSON_VALUE(@JsonObjectdata, '$.PriceListId'),
				JSON_VALUE(@JsonObjectdata, '$.DiscountListId'),
				'Monthly',
				JSON_VALUE(@JsonObjectdata, '$.AgreementReference'),
				JSON_VALUE(@JsonObjectdata, '$.AgreementDoc'),
				JSON_VALUE(@JsonObjectdata, '$.Descriptions'),
				CONVERT(BIT, JSON_VALUE(@JsonObjectdata, '$.HasGroup')),
				CONVERT(BIT, JSON_VALUE(@JsonObjectdata, '$.HasOverdraft')),
				1,0,
				JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)

				SET @AgreementId = SCOPE_IDENTITY();
				
			INSERT INTO CreditAgreements(AgreementId,CreditLimit,Paymentterms,LimitTypeId,AllowCredit,AllowedCredit,AutoAprovepo,Createdby,Modifiedby,Datecreated,Datemodified)
			VALUES(@AgreementId,JSON_VALUE(@JsonObjectdata, '$.LimitValue'),JSON_VALUE(@JsonObjectdata, '$.PaymentTerms'),(SELECT LimitTypeId FROM ConsumLimitType WHERE LimitTypename='Amount'),0,0,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))


			INSERT INTO CustomerAccount(AgreementId,AccountNumber,GroupingId,ParentId,CredittypeId,LimitTypeId,ConsumptionLimit,ConsumptionPeriod,Isadminactive,Iscustomeractive,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified)
			VALUES(@AgreementId, NEXT VALUE FOR AccountNumberSequence,JSON_VALUE(@JsonObjectdata, '$.GroupingId'),0,(SELECT CredittypeId FROM CreditTypes WHERE Credittypename='Postpaid'),JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimitType'),0,'Monthly',1,1,1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2))
				SET @AccountId = SCOPE_IDENTITY();
			INSERT INTO ChartofAccounts
			VALUES((SELECT AccountNumber FROM CustomerAccount WHERE AccountId=@AccountId),12)
		END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
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
