CREATE PROCEDURE [dbo].[Usp_Getcustomerpostpaidcreditagreementdatabyid]
	@CustomerAgreementId BIGINT
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
			SELECT A.AgreementId,A.CustomerId,A.GroupingId,A.AgreemettypeId,A.PriceListId,A.DiscountListId,A.BillingBasis,A.Descriptions,A.AgreementDoc,B.CreditLimit AS LimitValue,B.Paymentterms AS PaymentTerms,B.LimitTypeId AS ConsumptionLimitType,A.Notes,A.Hasgroup,A.HasOverdraft,A.IsActive,A.IsDeleted,A.Createdby,A.Modifiedby,A.Datecreated,A.Datemodified 
			FROM CustomerAgreements A INNER JOIN CreditAgreements B ON A.AgreementId=B.AgreementId  WHERE A.AgreementId=@CustomerAgreementId
			Set @RespMsg ='Ok.'
			Set @RespStat =0; 
		COMMIT TRANSACTION;
		
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage;

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
