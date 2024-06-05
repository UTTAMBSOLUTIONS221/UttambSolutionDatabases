CREATE PROCEDURE [dbo].[Usp_Getsystemcustomerdatabyid]
	@Customerid BIGINT
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
						SELECT Customerid,Tenantid,Firstname,Lastname,Imageurl,Customeremail,Phoneid,Phonenumber,Customerstatus,Idnumber,Krapin,Licensenumber,Gender,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated FROM Systemcustomers WHERE Customerid=@Customerid
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