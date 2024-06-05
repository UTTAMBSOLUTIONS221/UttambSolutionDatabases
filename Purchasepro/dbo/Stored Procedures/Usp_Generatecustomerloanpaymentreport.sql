--EXEC Usp_Generatecustomerloanpaymentreport
CREATE PROCEDURE [dbo].[Usp_Generatecustomerloanpaymentreport]
     @TenantId BIGINT,
     @Customerid BIGINT,
	 @Assetdetailid BIGINT,
     @Loanstatus INT,
     @Startdate DATETIME,
     @Enddate DATETIME,
	 @CustomerReportDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
	        @Customername VARCHAR(100),
		    @Assetdetailname VARCHAR(100),
			@Loanstatusname VARCHAR(40),
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Ok';
			
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;
		 SET @Customername = (SELECT CASE WHEN @Customerid<1 THEN 'ALL' ELSE a.Firstname+' '+a.Lastname END FROM Systemcustomers a WHERE (@Customerid<1 OR a.Customerid=@Customerid))
		 SET @Assetdetailname = (SELECT CASE WHEN @Assetdetailid<1 THEN 'ALL' ELSE a.Assetnumber END FROM Systemassetdetail a WHERE (@Assetdetailid<1 OR a.Assetdetailid=@Assetdetailid))
		 SET @Loanstatusname = (SELECT CASE WHEN @Loanstatus<0 THEN 'ALL' ELSE CASE WHEN @Loanstatus=0 THEN 'Fully Paid' WHEN @Loanstatus=1 THEN 'Partially Paid' WHEN @Loanstatus=2 THEN 'Not Due' END END)
		
		 SET @CustomerReportDetails = (
		  SELECT @RespStat AS RespStatus,@RespMsg AS RespMessage, @Customername AS Customername, @Assetdetailname AS Assetdetailname, @Loanstatusname AS Loanstatusname,@Startdate AS Startdate,@Enddate AS Enddate,
		  (
				SELECT c.Assetnumber,e.Vehiclemakename +' '+ f.Vehiclemodelname AS Assetname,a.Firstname+' '+a.Lastname AS Customername,g.Codename+ ''+ a.Phonenumber AS Phonenumber,aa.Period,aa.Paymentdate,aa.Paymentamount,aa.Currentbalance,aa.Interestamount,aa.Principalamount,ISNULL(ee.Recievedamount,0) AS PaidAmount ,CASE WHEN aa.Paymentstatus=0 THEN aa.Paymentamount-ee.Recievedamount WHEN aa.Paymentstatus=1 THEN aa.Paymentamount-ee.Recievedamount ELSE aa.Paymentamount END AS Weeklyoutstandingbalance,0 AS Cummulativeoutstandingbalance,
				CASE WHEN aa.Paymentstatus=0 THEN 'Fully Paid' WHEN aa.Paymentstatus=1 THEN 'Partially Paid' ELSE 'Not Due' END AS Paymentstatus,CASE WHEN aa.Paymentstatus=0 THEN 'Fully Paid' WHEN aa.Paymentstatus=1 THEN ee.Paymentmemo ELSE 'Not Due' END AS PaymentReason
				FROM Systemloandetailitems aa
				INNER JOIN  Systemloandetail b ON aa.Loandetailid= b.Loandetailid
				INNER JOIN Loanidaccountid cc ON cc.Loandetailid=aa.Loandetailid
				INNER JOIN Customeraccount dd ON cc.Accountid=dd.Accountid
				INNER JOIN SystemCustomers a ON aa.Customerid=a.Customerid
				INNER JOIN SystemPhonecodes g ON a.phoneid=g.phoneid
				INNER JOIN Systemassetdetail c ON  b.Assetdetailid=c.Assetdetailid
				INNER JOIN Systemvehiclemakes e ON c.Assetmakeid=e.Vehiclemakeid
				INNER JOIN Systemvehiclemodels f ON c.Assetmodelid=f.Vehiclemodelid
				LEFT JOIN Systemloanitempayments ee ON ee.Loandetailitemid=aa.Loandetailitemid
				WHERE a.TenantId = @TenantId AND (@Customerid<1 OR a.Customerid=@Customerid) AND (@Assetdetailid<1 OR b.Assetdetailid=@Assetdetailid) AND (@Loanstatus<0 OR aa.Paymentstatus=@Loanstatus) AND  aa.Paymentdate BETWEEN @Startdate AND @Enddate
			  FOR JSON PATH
		)  AS Loanrepaymentreportdata
		FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
		)
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
