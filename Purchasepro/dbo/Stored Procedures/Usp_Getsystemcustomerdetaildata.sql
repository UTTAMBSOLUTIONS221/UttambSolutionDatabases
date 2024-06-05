--EXEC Usp_Getsystemcustomerdetaildata @Customerid= 3,@CustomerDetails=''
CREATE PROCEDURE [dbo].[Usp_Getsystemcustomerdetaildata]
@Customerid BIGINT,
@CustomerDetails NVARCHAR(MAX) OUTPUT
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
		  SET @CustomerDetails = (SELECT  a.Customerid,a.Tenantid,a.Firstname,a.Lastname,ISNULL(a.Imageurl,'N/A') AS Imageurl,a.Customeremail,a.Phoneid,d.Codename+ ''+ a.Phonenumber AS Phonenumber,CASE WHEN a.Customerstatus =2 THEN 'Pending' WHEN a.Customerstatus =1 THEN 'Verified' ELSE 'Approved' END  AS Customerstatus,
		  a.Idnumber,a.Krapin,a.Licensenumber,CASE WHEN a.Gender =0 THEN 'Male' WHEN a.Customerstatus =1 THEN 'Female' ELSE 'General' END  AS Gender,ISNULL(a.Extra,'N/A') AS Extra,ISNULL(a.Extra1,'N/A') AS Extra1,ISNULL(a.Extra2,'N/A') AS Extra2,ISNULL(a.Extra3,'N/A') AS Extra3,
		  ISNULL(a.Extra4,'N/A') AS Extra4,ISNULL(a.Extra5,'N/A') AS Extra5,ISNULL(a.Extra6,'N/A') AS Extra6,ISNULL(a.Extra7,'N/A') AS Extra7,ISNULL(a.Extra8,'N/A') AS Extra8,ISNULL(a.Extra9,'N/A') AS Extra9 ,ISNULL(a.Extra10,'N/A') AS Extra10,a.Isactive,a.Isdeleted,a.Createdby,
		  a.Modifiedby,b.Firstname +' '+ b.Lastname  AS Createdbyname, c.Firstname +' '+ c.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated,
		  (
			  SELECT a.Loandetailid,a.Assetdetailid,a.Loanamount,a.Paidamount,a.Interestrate,a.Loanperiod,a.Paymentterm,a.Startdate,a.Laonstatus,
				  b.Customerid,b.Assetid,c.Assetname as Assetnametype,d.Vehiclemakename +' '+ e.Vehiclemodelname AS Assetname,b.Assetnumber,b.Assetmakeid,d.Vehiclemakename,b.Assetmodelid,e.Vehiclemodelname,b.Assetchasenumber,b.Yearofmanufacture,b.Tankcapacity,b.Odometerreading,  
				  a.Createdby,a.Modifiedby,f.Firstname +' '+ f.Lastname  AS Createdbyname, g.Firstname +' '+ g.Lastname AS Modifiedbyname,a.Datemodified,a.Datecreated
			  FROM Systemloandetail a
			  INNER JOIN Systemassetdetail b ON  a.Assetdetailid=b.Assetdetailid
			  INNER JOIN Systemassets c ON b.Assetid=c.Assetid
			  INNER JOIN Systemstaffs f ON a.Createdby=f.StaffId 
			  INNER JOIN Systemstaffs g ON a.Modifiedby=g.StaffId
			  LEFT JOIN Systemvehiclemakes d ON b.Assetmakeid=d.Vehiclemakeid
			  LEFT JOIN Systemvehiclemodels e ON b.Assetmodelid=e.Vehiclemodelid
			  WHERE a.Customerid= a.Customerid 
			  FOR JSON PATH
		  ) As Systemcustomerassets,
		  (
			  SELECT  aa.Loandetailitemid,aa.Loandetailid,c.AssetNumber,e.Vehiclemakename +' '+ f.Vehiclemodelname AS AssetName,dd.AccountNumber,cc.AccountId,aa.Customerid,aa.Period,aa.Paymentdate,aa.Paymentamount,aa.Currentbalance,aa.Interestamount,aa.Principalamount,(SELECT ISNULL(SUM(ee.Recievedamount),0) FROM Systemloanitempayments ee WHERE ee.Loandetailitemid=aa.Loandetailitemid) AS PaidAmount ,CASE WHEN aa.Paymentstatus=0 THEN aa.Paymentamount- (SELECT ISNULL(SUM(ee.Recievedamount),0) FROM Systemloanitempayments ee WHERE ee.Loandetailitemid=aa.Loandetailitemid) WHEN aa.Paymentstatus=1 THEN aa.Paymentamount-(SELECT ISNULL(SUM(ee.Recievedamount),0) FROM Systemloanitempayments ee WHERE ee.Loandetailitemid=aa.Loandetailitemid) ELSE aa.Paymentamount END AS Outstandingbalance,
			  aa.Paymentstatus,CASE WHEN aa.Paymentstatus=0 THEN 'Fully Paid' WHEN aa.Paymentstatus=1 THEN (SELECT ISNULL(ee.Paymentmemo,'Not Due') FROM Systemloanitempayments ee WHERE ee.Loandetailitemid=aa.Loandetailitemid) ELSE 'Not Due' END AS PaymentReason, aa.Extra1,aa.Extra2,aa.Extra3,aa.Extra4,aa.Extra5
			  FROM Systemloandetailitems aa
			  INNER JOIN  Systemloandetail b ON aa.Loandetailid= b.Loandetailid
			  INNER JOIN Loanidaccountid cc ON cc.Loandetailid=aa.Loandetailid
			  INNER JOIN Customeraccount dd ON cc.Accountid=dd.Accountid
			  INNER JOIN Systemassetdetail c ON  b.Assetdetailid=c.Assetdetailid
				INNER JOIN Systemvehiclemakes e ON c.Assetmakeid=e.Vehiclemakeid
				INNER JOIN Systemvehiclemodels f ON c.Assetmodelid=f.Vehiclemodelid
			  WHERE a.Customerid= aa.Customerid
			  FOR JSON PATH
		  ) AS Customerloanitems,
		  (
			 SELECT aa.AccountTopupId,aa.FinanceTransactionId,aa.AccountId,aa.Loandetailitemid,aa.Paymentamount,aa.Recievedamount,aa.ModeofPayment,aa.Paymentmemo,aa.Topupreference,aa.Topupreferencecode,
				  b.Firstname +' '+ b.Lastname  AS Createdbyname,c.TransactionCode,c.ParentId,c.Saledescription,c.SaleRefence,c.Createdby,c.ActualDate,c.DateCreated
			  FROM Systemloanitempayments aa
			  LEFT JOIN Systemstaffs b ON aa.Createdby=b.StaffId 
			  INNER JOIN  FinanceTransactions c ON aa.FinanceTransactionId=c.FinanceTransactionId
			  INNER JOIN  Systemloandetailitems ddd ON aa.Loandetailitemid=ddd.Loandetailitemid
			  INNER JOIN Loanidaccountid e ON e.Loandetailid=ddd.Loandetailid
			  INNER JOIN Customeraccount f ON e.Accountid=f.Accountid
			  WHERE a.Customerid= ddd.Customerid
			  FOR JSON PATH
		  ) AS Customerloanpayments
		  FROM Systemcustomers a
		  INNER JOIN Systemstaffs b ON a.Createdby=b.StaffId 
		  INNER JOIN Systemstaffs c ON a.Modifiedby=c.StaffId
		  INNER JOIN SystemPhonecodes d ON a.phoneid=d.phoneid
		  WHERE a.Customerid = @Customerid
		  FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
		  )
	    Set @RespMsg ='Ok.'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@CustomerDetails AS CustomerDetails

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