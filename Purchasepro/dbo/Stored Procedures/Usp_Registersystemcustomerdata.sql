CREATE PROCEDURE [dbo].[Usp_Registersystemcustomerdata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = ''
			BEGIN
	
		BEGIN TRY	
		--Validate
		BEGIN TRANSACTION;
		IF(JSON_VALUE(@JsonObjectdata, '$.Customerid')=0)
			BEGIN
				INSERT INTO Systemcustomers(Tenantid,Firstname,Lastname,Imageurl,Customeremail,Phoneid,Phonenumber,Customerstatus,Idnumber,Krapin,Licensenumber,Gender,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Tenantid'),JSON_VALUE(@JsonObjectdata, '$.Firstname'),JSON_VALUE(@JsonObjectdata, '$.Lastname'),JSON_VALUE(@JsonObjectdata, '$.Imageurl'),JSON_VALUE(@JsonObjectdata, '$.Customeremail'),JSON_VALUE(@JsonObjectdata, '$.Phoneid'),
				JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),2,JSON_VALUE(@JsonObjectdata, '$.Idnumber'),JSON_VALUE(@JsonObjectdata, '$.Krapin'),JSON_VALUE(@JsonObjectdata, '$.Licensenumber'),JSON_VALUE(@JsonObjectdata, '$.Gender'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
				Set @RespMsg ='Customer Saved Successfully.'
				Set @RespStat =0; 
			END
		ELSE
			BEGIN
				UPDATE Systemcustomers SET Firstname=JSON_VALUE(@JsonObjectdata, '$.Firstname'), Lastname=JSON_VALUE(@JsonObjectdata, '$.Lastname'),Imageurl=JSON_VALUE(@JsonObjectdata, '$.Imageurl'),Customeremail=JSON_VALUE(@JsonObjectdata, '$.Customeremail'),Phoneid=JSON_VALUE(@JsonObjectdata, '$.Phoneid'),Phonenumber=JSON_VALUE(@JsonObjectdata, '$.Phonenumber'),Idnumber=JSON_VALUE(@JsonObjectdata, '$.Idnumber'),
				Krapin=JSON_VALUE(@JsonObjectdata, '$.Krapin'),Licensenumber=JSON_VALUE(@JsonObjectdata, '$.Licensenumber'),Gender=JSON_VALUE(@JsonObjectdata, '$.Gender'),Extra=JSON_VALUE(@JsonObjectdata, '$.Extra'),Extra1=JSON_VALUE(@JsonObjectdata, '$.Extra1'),Extra2=JSON_VALUE(@JsonObjectdata, '$.Extra2'),Extra3=JSON_VALUE(@JsonObjectdata, '$.Extra3'),Extra4=JSON_VALUE(@JsonObjectdata, '$.Extra4'),Extra5=JSON_VALUE(@JsonObjectdata, '$.Extra5'),Extra6=JSON_VALUE(@JsonObjectdata, '$.Extra6'),Extra7=JSON_VALUE(@JsonObjectdata, '$.Extra7'),Extra8=JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				Extra9=JSON_VALUE(@JsonObjectdata, '$.Extra9'),Extra10=JSON_VALUE(@JsonObjectdata, '$.Extra10'),Modifiedby=JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),Datemodified=CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2) WHERE Customerid=JSON_VALUE(@JsonObjectdata, '$.Customerid')
				Set @RespMsg ='Customer Updated Successfully.'
				Set @RespStat =0; 
			END
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