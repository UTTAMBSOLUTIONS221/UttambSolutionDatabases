CREATE PROCEDURE [dbo].[Usp_GetSystemLoyaltyFormulaData]
    @TenantId BIGINT,
	@LoyaltyFormulaDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;
		SET @LoyaltyFormulaDetails =(
		SELECT(
		SELECT a.FormulaId,a.FormulaName,a.ValueType,a.CreatedBy,a.ModifiedBy,a.DateCreated,a.DateModified,
        (
          SELECT FormulaRuleId,FormulaId,Range1,Range2,IsRangetoInfinity,Formula,IsApproved,ApprovalLevel,CreatedBy,ModifiedBy,DateCreated,DateModified
		  FROM LFormulaRules aa
            WHERE 
                a.FormulaId = aa.FormulaId
            FOR JSON PATH
        ) AS SystemFormulaRules
       FROM LFormulas a
		LEFT JOIN  SystemStaffs b ON a.CreatedBy=b.Userid
		LEFT JOIN  SystemStaffs c ON a.ModifiedBy=c.Userid
	    WHERE a.Tenantid=@TenantId
        FOR JSON PATH
	  ) AS Formula
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER 
		)
	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@LoyaltyFormulaDetails as LoyaltyFormulaDetails;

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
