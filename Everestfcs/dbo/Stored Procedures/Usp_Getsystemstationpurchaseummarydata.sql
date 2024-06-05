CREATE PROCEDURE [dbo].[Usp_Getsystemstationpurchaseummarydata]
	@StationId BIGINT,
	@StartDate DATETIME,
	@EndDate DATETIME
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
		SELECT C.InvoiceDate,D.Sname AS StatonName,C.InvoiceNumber,C.InvoiceAmount,C.TruckNumber,C.DriverName,B.Productvariationname,A.PurchaseQuantity,A.PurchasePrice,A.PurchaseDiscount,A.PurchaseTotal,E.Firstname+' '+E.Lastname AS Createdby,F.Firstname+' '+F.Lastname AS Modifiedby,A.Datemodified,A.Datecreated 
		FROM StationPurchaseItems A 
		INNER JOIN SystemProductvariation B ON B.ProductVariationId=A.ProductVariationId
		INNER JOIN StationPurchases C ON A.PurchaseId=C.PurchaseId
		INNER JOIN SystemStations D ON C.StationId=D.StationId
		INNER JOIN SystemStaffs E ON A.Createdby=E.Userid
		INNER JOIN SystemStaffs F ON A.Createdby=F.Userid
		WHERE A.Datecreated BETWEEN @StartDate AND @EndDate AND (C.StationId=@StationId OR 0=@StationId)
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