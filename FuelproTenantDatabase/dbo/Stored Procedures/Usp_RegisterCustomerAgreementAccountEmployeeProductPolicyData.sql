CREATE PROCEDURE [dbo].[Usp_RegisterCustomerAgreementAccountEmployeeProductPolicyData]
 @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE @RespStat int = 0,
			@RespMsg varchar(150) = '',
			@EmployeeId BIGINT;
			BEGIN
	
		BEGIN TRY	
		--Validate
		IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeProductId')=0)
		BEGIN
			IF EXISTS(SELECT EmployeeProductId FROM EmployeeProducts WHERE EmployeeProductId=JSON_VALUE(@JsonObjectdata, '$.EmployeeProductId'))
			BEGIN
				Select  1 as RespStatus, 'Similar Product exists!. Contact Admin!' as RespMessage;
				Return
			END
		END
		BEGIN TRANSACTION;
			IF(JSON_VALUE(@JsonObjectdata, '$.EmployeeProductId')>0)
			BEGIN
				UPDATE EmployeeProducts SET ProductVariationId=JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),LimitValue=JSON_VALUE(@JsonObjectdata, '$.LimitValue'),LimitPeriod=JSON_VALUE(@JsonObjectdata, '$.LimitPeriod'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),DateModified=CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2) WHERE EmployeeProductId=JSON_VALUE(@JsonObjectdata, '$.EmployeeProductId')
			END
			ELSE
			BEGIN
				INSERT INTO EmployeeProducts(EmployeeId,ProductVariationId,LimitValue,LimitPeriod,Createdby,Modifiedby,DateCreated,DateModified)
				SELECT JSON_VALUE(@JsonObjectdata, '$.EmployeeId'),JSON_VALUE(@JsonObjectdata, '$.ProductVariationId'),JSON_VALUE(@JsonObjectdata, '$.LimitValue'),
				JSON_VALUE(@JsonObjectdata, '$.LimitPeriod'),JSON_VALUE(@JsonObjectdata, '$.CreatedBy'),JSON_VALUE(@JsonObjectdata, '$.ModifiedBy'),
				CAST(JSON_VALUE(@JsonObjectdata, '$.DateCreated') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.DateModified')  AS datetime2)
			END

		Set @RespMsg ='Success';
		Set @RespStat =0; 
		COMMIT TRANSACTION;
		Select @RespStat as RespStatus, @RespMsg as RespMessage,JSON_VALUE(@JsonObjectdata, '$.EmployeeId') AS Data1;

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

select * from EmployeeProducts