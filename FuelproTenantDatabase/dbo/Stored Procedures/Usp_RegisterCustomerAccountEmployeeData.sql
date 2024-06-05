CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAccountEmployeeData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@Data1 VARCHAR(250)= '',
			@Data2 VARCHAR(250)= '',
			@EmployeeId BIGINT;
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeId')=0)
		BEGIN
			IF EXISTS(SELECT EmployeeId FROM CustomerEmployees WHERE Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'))
			BEGIN
				Select  1 as RespStatus, 'Similar Emailaddress exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeId')>0)
		BEGIN
		     UPDATE CustomerEmployees SET Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'),Lastname=JSON_VALUE(@JsonObjectdata, '$.Lastname'),Emailaddress=JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),Datemodofied=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2) WHERE EmployeeId=JSON_VALUE(@JsonObjectdata, '$.EmployeeId');
			 Select @Data1 =Employeecode,@Data2=Codeharshkey FROM CustomerEmployees WHERE EmployeeId= JSON_VALUE(@JsonObjectdata, '$.EmployeeId');
		END
		ELSE
		BEGIN
			INSERT INTO CustomerEmployees(Firstname,Lastname,Emailaddress,Codeharshkey,Employeecode,Changecode,Createdby,Modifiedby,Datecreated,Datemodofied)
			SELECT JSON_VALUE(@JsonObjectdata, '$.Firstname'),JSON_VALUE(@JsonObjectdata, '$.Lastname'),JSON_VALUE(@JsonObjectdata, '$.Emailaddress'),JSON_VALUE(@JsonObjectdata, '$.Employeeharhcode'),
			JSON_VALUE(@JsonObjectdata, '$.Employeecode'),1,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.ModifiedId'),
			CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified')  AS datetime2)

		    SET @EmployeeId=SCOPE_IDENTITY();

			INSERT INTO AccountEmployee(AccountId,EmployeeId)
			VALUES(JSON_VALUE(@JsonObjectdata, '$.AccountId'),@EmployeeId)

		  Select @Data1 =Employeecode,@Data2=Codeharshkey FROM CustomerEmployees WHERE EmployeeId= @EmployeeId;
         END

		Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,@Data1 AS Data1,@Data2 AS Data2;

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