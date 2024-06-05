


CREATE PROCEDURE [dbo].[Usp_RegisterCustomerPostpaidOneOffAgreementData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE  
			@AgreementId BIGINT,
			@AccountId BIGINT,
			@consumptiontype VARCHAR(40),
			@BillingCycle VARCHAR(40),
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

			BEGIN
	
		BEGIN TRY	
		--Validate

		BEGIN TRANSACTION;
		IF((SELECT JSON_VALUE(@JsonObjectdata, '$.AgreementId'))>0)
		BEGIN
		 UPDATE Customers SET 
		 Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),
		 Lastname= JSON_VALUE(@JsonObjectdata, '$.Lastname'),
		 Companyname= JSON_VALUE(@JsonObjectdata, '$.Companyname'),
		 Emailaddress= JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),
		 Phonenumber= JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),
		 Dob=  CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2),
		 Gender= JSON_VALUE(@JsonObjectdata, '$.Gender'),
		 IDNumber= JSON_VALUE(@JsonObjectdata, '$.IDNumber'),
		 Designation= JSON_VALUE(@JsonObjectdata, '$.Designation'),
		 Pin= JSON_VALUE(@JsonObjectdata, '$.Pin'),
		 Pinharsh= JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),
		 CompanyAddress= JSON_VALUE(@JsonObjectdata, '$.CompanyAddress'),
		 ReferenceNumber= JSON_VALUE(@JsonObjectdata, '$.ReferenceNumber'),
         CompanyIncorporationDate= CAST(JSON_VALUE(@JsonObjectdata, '$.CompanyIncorporationDate') AS datetime2),
		 CompanyRegistrationNo= JSON_VALUE(@JsonObjectdata, '$.CompanyRegistrationNo'),
		 CompanyPIN= JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),
		 CompanyVAT= JSON_VALUE(@JsonObjectdata, '$.CompanyVAT'),
		 Contractstartdate= CAST(JSON_VALUE(@JsonObjectdata, '$.Contractstartdate') AS datetime2),
		 Contractenddate= CAST(JSON_VALUE(@JsonObjectdata, '$.Contractenddate')AS datetime2),
		 StationId= JSON_VALUE(@JsonObjectdata, '$.StationId'),
		 CountryId= JSON_VALUE(@JsonObjectdata, '$.CountryId'),
		 NoOfTransactionPerDay= JSON_VALUE(@JsonObjectdata, '$.NoOfTransactionPerDay'),
		 AmountPerDay= JSON_VALUE(@JsonObjectdata, '$.AmountPerDay'),
		ConsecutiveTransTimeMin= JSON_VALUE(@JsonObjectdata, '$.ConsecutiveTransTimeMin'),
		IsPortaluser=  JSON_VALUE(@JsonObjectdata, '$.IsPortaluser'),
		Extra= JSON_VALUE(@JsonObjectdata, '$.Extra'),
		Extra1= JSON_VALUE(@JsonObjectdata, '$.Extra1'),
		Extra2= JSON_VALUE(@JsonObjectdata, '$.Extra2'),
		Extra3= JSON_VALUE(@JsonObjectdata, '$.Extra3'),
		Extra4= JSON_VALUE(@JsonObjectdata, '$.Extra4'),
		Extra5= JSON_VALUE(@JsonObjectdata, '$.Extra5'),
		Extra6= JSON_VALUE(@JsonObjectdata, '$.Extra6'),
		Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),
		Extra8= JSON_VALUE(@JsonObjectdata, '$.Extra8'),
		Extra9= JSON_VALUE(@JsonObjectdata, '$.Extra9'), 
		 Modifiedby= JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),
		 Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)
		 WHERE CustomerId= JSON_VALUE(@JsonObjectdata, '$.CustomerId')
		END
		ELSE
		BEGIN
		 SET @consumptiontype= (SELECT LimitTypename FROM ConsumLimitType WHERE LimitTypeId=JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimitType')) 
		    INSERT INTO CustomerAgreements(CustomerId,GroupingId,AgreemettypeId,PriceListId,DiscountListId,BillingBasis,Descriptions,AgreementDoc,Notes,Hasgroup,HasOverdraft,IsActive,IsDeleted,Createdby,Modifiedby,Datecreated,Datemodified)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.CustomerId'),
				JSON_VALUE(@JsonObjectdata, '$.GroupingId'),
				
				(SELECT AgreemettypeId FROM AgreementTypes WHERE Agreementtypename='OneOff-'+@consumptiontype+'-Agreement'),
				JSON_VALUE(@JsonObjectdata, '$.PriceListId'),
				JSON_VALUE(@JsonObjectdata, '$.DiscountListId'),
				JSON_VALUE(@JsonObjectdata, '$.BillingBasis'),
				JSON_VALUE(@JsonObjectdata, '$.Reference'),
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
				
			INSERT INTO PostpaidOneOffAgreements(AgreementId,Amount,StartDate,DueDate,AvailableBalance,GracePeriod,IsPaid,AgreementRef,IsLPOExpired,DoesPayCloseLPO,Createdby,Modifiedby,DateCreated,DateModified)
			VALUES(@AgreementId,JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimitValue'),JSON_VALUE(@JsonObjectdata, '$.StartDate'),JSON_VALUE(@JsonObjectdata, '$.EndDate'),JSON_VALUE(@JsonObjectdata, '$.ConsumptionLimitValue'),
			JSON_VALUE(@JsonObjectdata, '$.GracePeriod'),0,JSON_VALUE(@JsonObjectdata, '$.Reference'),0,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
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