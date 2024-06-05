CREATE PROCEDURE [dbo].[Usp_Getsystemcustomerdata]
@TenantId BIGINT
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
		  SELECT  a.Customerid,a.Tenantid,a.Firstname,a.Lastname,ISNULL(a.Imageurl,'N/A') AS Imageurl,a.Customeremail,a.Phoneid,d.Codename+ ''+ a.Phonenumber AS Phonenumber,CASE WHEN a.Customerstatus =2 THEN 'Pending' WHEN a.Customerstatus =1 THEN 'Verified' ELSE 'Approved' END  AS Customerstatus,
		  a.Idnumber,a.Krapin,a.Licensenumber,CASE WHEN a.Gender =0 THEN 'Male' WHEN a.Customerstatus =1 THEN 'Female' ELSE 'General' END  AS Gender,ISNULL(a.Extra,'N/A') AS Extra,ISNULL(a.Extra1,'N/A') AS Extra1,ISNULL(a.Extra2,'N/A') AS Extra2,ISNULL(a.Extra3,'N/A') AS Extra3,
		  ISNULL(a.Extra4,'N/A') AS Extra4,ISNULL(a.Extra5,'N/A') AS Extra5,ISNULL(a.Extra6,'N/A') AS Extra6,ISNULL(a.Extra7,'N/A') AS Extra7,ISNULL(a.Extra8,'N/A') AS Extra8,ISNULL(a.Extra9,'N/A') AS Extra9 ,ISNULL(a.Extra10,'N/A') AS Extra10,a.Isactive,a.Isdeleted,a.Createdby,
		  a.Modifiedby,b.Firstname +' '+ b.Lastname  AS Createdbyname, c.Firstname +' '+ c.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated
		  FROM Systemcustomers a
		  INNER JOIN Systemstaffs b ON a.Createdby=b.StaffId 
		  INNER JOIN Systemstaffs c ON a.Modifiedby=c.StaffId
		  INNER JOIN SystemPhonecodes d ON a.phoneid=d.phoneid
		  WHERE a.Tenantid = @TenantId
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