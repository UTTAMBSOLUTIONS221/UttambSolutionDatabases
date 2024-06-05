CREATE PROCEDURE [dbo].[Usp_GetSystemGadgetsData]
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
		SELECT a.GadgetId,a.GadgetName,a.Descriptions,COALESCE(a.Imei1,'Not Set') AS Imei1,COALESCE(a.Imei12,'Not Set') AS Imei2,a.Serialnumber,c.Sname AS Station,a.IsActive,a.IsDeleted,a.Createdby,a.Modifiedby,
			  (CASE WHEN  EXISTS (SELECT LnkGadgetsStation.GadgetId FROM LnkGadgetsStation WHERE LnkGadgetsStation.GadgetId = a.GadgetId) THEN 'Assigned' ELSE 'Not Assigned' END) AS IsAssigned,
			  d.Firstname +' '+ d.Lastname  AS Createdby,d.Firstname +' '+ d.Lastname  AS Modifiedby,a.DateCreated,a.DateModified
		  FROM SystemGadgets a 
		  LEFT JOIN LnkGadgetsStation b ON b.GadgetId=a.GadgetId
		  LEFT JOIN SystemStations c ON b.StationId=c.StationId
		  LEFT JOIN Tenantusers d ON a.Createdby=d.Userid
		  LEFT JOIN Tenantusers e ON a.Modifiedby=e.Userid
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
