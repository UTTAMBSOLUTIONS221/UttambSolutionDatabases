CREATE PROCEDURE [dbo].[Usp_GetSystemTenantCardData]
	@Offset INT,
	@Count INT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	
		If(@Count=0)
		BEGIN
		 SET @Count=10;
		END
		BEGIN TRANSACTION;
		SELECT a.CardId,a.CardUID,a.CardSNO,ISNULL(a.CardCode,'N/A') AS CardCode,ISNULL(CASE WHEN Designation='Corporate' THEN f.Companyname ELSE f.Firstname+' '+ f.Lastname END ,'No Customer') AS Customername,a.PIN,a.PinHarsh,a.IsActive,a.IsDeleted,a.IsAssigned,a.IsReplaced,a.TagtypeId,b.TagTypeName,g.Fullname AS CreatedByFullName,h.Fullname AS ModifiedbyFullname,a.Createdby,a.Modifiedby,a.Datecreated,a.Datemodified
		FROM Systemcard a 
		INNER JOIN Systemcardtype b ON a.TagtypeId=b.TagtypeId
		LEFT JOIN SystemAccountCards c ON a.CardId=c.CardId
		LEFT JOIN CustomerAccount d ON c.AccountId=d.AccountId
		LEFT JOIN CustomerAgreements e ON d.AgreementId=e.AgreementId
		LEFT JOIN Customers f ON e.CustomerId=f.Customerid
		INNER JOIN SystemStaffs g ON a.Createdby=g.UserId
		INNER JOIN SystemStaffs h ON a.Createdby=h.UserId
		WHERE IsReplaced=0
		ORDER BY a.Datecreated
		OFFSET @Offset ROWS
		FETCH NEXT @Count ROWS ONLY;

	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage

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