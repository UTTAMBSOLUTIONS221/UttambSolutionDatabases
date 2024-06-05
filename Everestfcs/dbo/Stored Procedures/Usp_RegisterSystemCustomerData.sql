


CREATE PROCEDURE [dbo].[Usp_RegisterSystemCustomerData]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @CountryId BIGINT= 0,
			@CustomerId BIGINT= 0,
			@RespStat int = 0,
			@RespMsg varchar(150) = '';

			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.CustomerId')=0)
		BEGIN
			IF EXISTS(SELECT CustomerId FROM Customers WHERE Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
			BEGIN
				Select  1 as RespStatus, 'Similar Email Address exists!. Contact Admin!' as RespMessage;
				Return
			END
			IF EXISTS(SELECT CustomerId FROM Customers WHERE Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
			BEGIN
				Select  1 as RespStatus, 'Similar Phonenumber exists!. Contact Admin!' as RespMessage;
				Return
			END
			IF EXISTS(SELECT CustomerId FROM Customers WHERE IDNumber=JSON_VALUE(@JsonObjectdata, '$.IDNumber') AND TenantId=JSON_VALUE(@JsonObjectdata, '$.TenantId'))
			BEGIN
				Select  1 as RespStatus, 'Similar ID Number exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		IF((SELECT JSON_VALUE(@JsonObjectdata, '$.CustomerId'))>0)
		BEGIN
		 IF(JSON_VALUE(@JsonObjectdata, '$.CountryId')!=0)
		 BEGIN
		  SET @CountryId=JSON_VALUE(@JsonObjectdata, '$.CountryId');
		 END
		 ELSE
		 BEGIN
		 SET @CountryId=(SELECT TOP 1 CountryId FROM SystemCountry);
		 END
		 UPDATE Customers SET 
		 Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),
		 Lastname= JSON_VALUE(@JsonObjectdata, '$.Lastname'),
		 Companyname= JSON_VALUE(@JsonObjectdata, '$.Companyname'),
		 Emailaddress= JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),
		 Phoneid= JSON_VALUE(@JsonObjectdata, '$.Phoneid'),
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
		 CountryId= @CountryId,
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
		 Modifiedby= JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
		 Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)
		 WHERE CustomerId= JSON_VALUE(@JsonObjectdata, '$.CustomerId')
		END
		ELSE
		BEGIN
		 IF(JSON_VALUE(@JsonObjectdata, '$.CountryId')!=0)
		 BEGIN
		  SET @CountryId=JSON_VALUE(@JsonObjectdata, '$.CountryId');
		 END
		 ELSE
		 BEGIN
		 SET @CountryId=(SELECT TOP 1 CountryId FROM SystemCountry);
		 END


			 INSERT INTO Customers(Tenantid,Firstname,Lastname,Companyname,Emailaddress,Phoneid,Phonenumber,Dob,Gender,IDNumber,Designation,Pin,Pinharsh,CompanyAddress,ReferenceNumber
             ,CompanyIncorporationDate,CompanyRegistrationNo,CompanyPIN,CompanyVAT,Contractstartdate,Contractenddate,StationId,CountryId,NoOfTransactionPerDay,AmountPerDay,
			 ConsecutiveTransTimeMin,IsPortaluser,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Createdby, Modifiedby,Datecreated,Datemodified)
			SELECT
				JSON_VALUE(@JsonObjectdata, '$.TenantId'),
				JSON_VALUE(@JsonObjectdata, '$.Firstname'),
				JSON_VALUE(@JsonObjectdata, '$.Lastname'),
				JSON_VALUE(@JsonObjectdata, '$.Companyname'),
				JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),
				JSON_VALUE(@JsonObjectdata, '$.Phoneid'),
				JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Dob')  AS datetime2),
				JSON_VALUE(@JsonObjectdata, '$.Gender'),
				JSON_VALUE(@JsonObjectdata, '$.IDNumber'),
				JSON_VALUE(@JsonObjectdata, '$.Designation'),
				JSON_VALUE(@JsonObjectdata, '$.Pin'),
				JSON_VALUE(@JsonObjectdata, '$.Pinharsh'),
				JSON_VALUE(@JsonObjectdata, '$.CompanyAddress'),
				JSON_VALUE(@JsonObjectdata, '$.ReferenceNumber'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.CompanyIncorporationDate')  AS datetime2),
				JSON_VALUE(@JsonObjectdata, '$.CompanyRegistrationNo'),
				JSON_VALUE(@JsonObjectdata, '$.CompanyPIN'),
				JSON_VALUE(@JsonObjectdata, '$.CompanyVAT'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Contractstartdate')  AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Contractenddate')  AS datetime2),
				JSON_VALUE(@JsonObjectdata, '$.StationId'),
				@CountryId,
				JSON_VALUE(@JsonObjectdata, '$.NoOfTransactionPerDay'),
				JSON_VALUE(@JsonObjectdata, '$.AmountPerDay'),
				JSON_VALUE(@JsonObjectdata, '$.ConsecutiveTransTimeMin'),
				1,
				JSON_VALUE(@JsonObjectdata, '$.Extra'),
				JSON_VALUE(@JsonObjectdata, '$.Extra1'),
				JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				JSON_VALUE(@JsonObjectdata, '$.Extra3'),
				JSON_VALUE(@JsonObjectdata, '$.Extra4'),
				JSON_VALUE(@JsonObjectdata, '$.Extra5'),
				JSON_VALUE(@JsonObjectdata, '$.Extra6'),
				JSON_VALUE(@JsonObjectdata, '$.Extra7'),
				JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				JSON_VALUE(@JsonObjectdata, '$.Extra9'),
				JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),
				JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),
				CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)
				SET @CustomerId =SCOPE_IDENTITY();
		END
		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerId AS Data1, 'Insert' AS Data2;

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
