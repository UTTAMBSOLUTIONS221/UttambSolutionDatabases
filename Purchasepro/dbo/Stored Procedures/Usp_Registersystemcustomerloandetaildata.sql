CREATE PROCEDURE [dbo].[Usp_Registersystemcustomerloandetaildata]
    @JsonObjectdata NVARCHAR(MAX)
AS
BEGIN
   BEGIN
	DECLARE 
	        @Insertedloandetailid BIGINT,
			@Insertedassetdetailid BIGINT,
			@Insertedcustomeraccountid BIGINT,
			@Insertedfinancetransactionlid BIGINT,
			@Monthorweek VARCHAR(14),
			@i INT,
			@PaymentFrequency INT,
			@RespStat int = 0,
			@InterestPaid DECIMAL(18,2) =0,
			@PrincipalPaid DECIMAL(18, 2) =0,
			@RespMsg varchar(150) = '';
			BEGIN	
				BEGIN TRY	
				--Validate
				BEGIN TRANSACTION;
				
				INSERT INTO CustomerAccount(CustomerId,AccountNumber,IsActive,IsDeleted,Createdby,Datecreated)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Customerid'),NEXT VALUE FOR AccountNumberSequence,1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
				IF(SCOPE_IDENTITY()<0)
				BEGIN
				  return;
				END
				ELSE
				BEGIN 
				 SET @Insertedcustomeraccountid=SCOPE_IDENTITY();
				END
				
				INSERT INTO ChartofAccounts(ChartofAccountname)
				SELECT AccountNumber FROM CustomerAccount WHERE AccountId=@Insertedcustomeraccountid
				IF(SCOPE_IDENTITY()<0)
				BEGIN
				   return;
				END

				INSERT INTO Systemassetdetail(Customerid,Assetid,Assetnumber,Assetmakeid,Assetmodelid,Assetchasenumber,Yearofmanufacture,Tankcapacity,Odometerreading,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Customerid'),JSON_VALUE(@JsonObjectdata, '$.Assetid'),JSON_VALUE(@JsonObjectdata, '$.Assetnumber'),JSON_VALUE(@JsonObjectdata, '$.Assetmakeid'),JSON_VALUE(@JsonObjectdata, '$.Assetmodelid'),
				JSON_VALUE(@JsonObjectdata, '$.Assetchasenumber'),JSON_VALUE(@JsonObjectdata, '$.Yearofmanufacture'),JSON_VALUE(@JsonObjectdata, '$.Tankcapacity'),JSON_VALUE(@JsonObjectdata, '$.Odometerreading'),JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))

				IF(SCOPE_IDENTITY()<0)
				BEGIN
				  return;
				END
				ELSE
				BEGIN 
				 SET @Insertedassetdetailid=SCOPE_IDENTITY();
				END

				INSERT INTO Systemloandetail(Customerid,Assetdetailid,Loanamount,Paidamount,Interestrate,Loanperiod,Paymentterm,Startdate,Laonstatus,Extra,Extra1,Extra2,Extra3,Extra4,Extra5,Extra6,Extra7,Extra8,Extra9,Extra10,Isactive,Isdeleted,Createdby,Modifiedby,Datemodified,Datecreated)
				(SELECT JSON_VALUE(@JsonObjectdata, '$.Customerid'),@Insertedassetdetailid,JSON_VALUE(@JsonObjectdata, '$.Loanamount'),JSON_VALUE(@JsonObjectdata, '$.Paidamount'),JSON_VALUE(@JsonObjectdata, '$.Interestrate'),JSON_VALUE(@JsonObjectdata, '$.Loanperiod'),JSON_VALUE(@JsonObjectdata, '$.Paymentterm'),CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2),
				3,JSON_VALUE(@JsonObjectdata, '$.Extra'),JSON_VALUE(@JsonObjectdata, '$.Extra1'),JSON_VALUE(@JsonObjectdata, '$.Extra2'),
				JSON_VALUE(@JsonObjectdata, '$.Extra3'),JSON_VALUE(@JsonObjectdata, '$.Extra4'),JSON_VALUE(@JsonObjectdata, '$.Extra5'),JSON_VALUE(@JsonObjectdata, '$.Extra6'),JSON_VALUE(@JsonObjectdata, '$.Extra7'),JSON_VALUE(@JsonObjectdata, '$.Extra8'),
				JSON_VALUE(@JsonObjectdata, '$.Extra9'),JSON_VALUE(@JsonObjectdata, '$.Extra10'),1,0,JSON_VALUE(@JsonObjectdata, '$.Createdby'),JSON_VALUE(@JsonObjectdata, '$.Modifiedby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2))
				
				IF(SCOPE_IDENTITY()<0)
				BEGIN
				  return;
				END
				ELSE
				BEGIN 
				 SET @Insertedloandetailid=SCOPE_IDENTITY();
				END

				INSERT INTO Loanidaccountid(Accountid,Loandetailid)
				VALUES(@Insertedcustomeraccountid,@Insertedloandetailid)
				IF(SCOPE_IDENTITY()<0)
				BEGIN
				   return;
				END

				IF(JSON_VALUE(@JsonObjectdata, '$.Paymentterm')='Monthly')
				BEGIN
				 SET @Monthorweek ='MONTH';
				 SET @PaymentFrequency=12;
				END			
				ELSE
				BEGIN
				 SET @Monthorweek ='WEEk';
				 SET @PaymentFrequency=52;
				END
		
				DECLARE @P DECIMAL(18, 2) = CAST(JSON_VALUE(@JsonObjectdata, '$.Loanamount') AS DECIMAL(12, 2));
				DECLARE @r DECIMAL(18, 6) = (CAST(JSON_VALUE(@JsonObjectdata, '$.Interestrate') AS DECIMAL(12, 2)) / 100) / @PaymentFrequency;  -- Monthly or Weekly
				DECLARE @n INT = CAST(JSON_VALUE(@JsonObjectdata, '$.Loanperiod') AS DECIMAL(12, 2)) * @PaymentFrequency;  -- Total number of payments

				-- Calculate EMI
				DECLARE @EMI DECIMAL(18, 2);
				SET @EMI = @P * (@r * POWER(1 + @r, @n)) / (POWER(1 + @r, @n) - 1);

				-- Calculate remaining balance for each payment
				DECLARE @Balance DECIMAL(18, 2) = @P;

				
				IF(JSON_VALUE(@JsonObjectdata, '$.Paymentterm')='Monthly')
					BEGIN
						-- Insert the initial payment into the temporary table
						INSERT INTO Systemloandetailitems(Loandetailid,Customerid,Period,Paymentdate,Paymentamount,Currentbalance,Interestamount,Principalamount,Paymentstatus,Payementreason,Extra1,Extra2,Extra3,Extra4,Extra5)
						VALUES (@Insertedloandetailid,CAST(JSON_VALUE(@JsonObjectdata, '$.Customerid') AS BIGINT),1,CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2),@EMI,@P,0,0,2,'Not Paid',NULL,NULL,NULL,NULL,NULL);
						INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
						VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Loan','LoandData',JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						IF(SCOPE_IDENTITY()<0)
						BEGIN
						  return;
						END
						ELSE
						BEGIN 
						 SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
						END
						INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
						VALUES (@Insertedfinancetransactionlid,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=@Insertedcustomeraccountid)),@EMI,CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						
						SET @i = 1;
						WHILE @i <= @n
						BEGIN
							-- Calculate the interest component for this payment
							SET @InterestPaid = @Balance * @r;
							-- Calculate the principal component for this payment
							SET @PrincipalPaid  = @EMI - @InterestPaid;
						  -- Ensure the remaining balance doesn't go negative
							IF (@Balance - @PrincipalPaid) < 0
							BEGIN
								SET @PrincipalPaid = @Balance;
								SET @InterestPaid = @EMI - @PrincipalPaid;
							END
							-- Calculate the remaining balance after this payment
							SET @Balance = @Balance - @PrincipalPaid;
							INSERT INTO Systemloandetailitems(Loandetailid,Customerid,Period,Paymentdate,Paymentamount,Currentbalance,Interestamount,Principalamount,Paymentstatus,Payementreason,Extra1,Extra2,Extra3,Extra4,Extra5)
							VALUES (@Insertedloandetailid,CAST(JSON_VALUE(@JsonObjectdata, '$.Customerid') AS BIGINT),@i + 1,DATEADD(MONTH, @i, CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2)),@EMI,@Balance,@InterestPaid,@PrincipalPaid,2,'Not Paid',NULL,NULL,NULL,NULL,NULL);
							INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
							VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Loan','LoandData',JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
							IF(SCOPE_IDENTITY()<0)
							BEGIN
							  return;
							END
							ELSE
							BEGIN 
							 SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
							END
							INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
							VALUES (@Insertedfinancetransactionlid,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=@Insertedcustomeraccountid)),@EMI,CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						
							SET @i = @i + 1;
						END
					END 
				ELSE
					BEGIN
						 -- Insert the initial payment into the temporary table
						INSERT INTO Systemloandetailitems(Loandetailid,Customerid,Period,Paymentdate,Paymentamount,Currentbalance,Interestamount,Principalamount,Paymentstatus,Payementreason,Extra1,Extra2,Extra3,Extra4,Extra5)
						VALUES (@Insertedloandetailid,CAST(JSON_VALUE(@JsonObjectdata, '$.Customerid') AS BIGINT),1,CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2),@EMI,@P,0,0,2,'Not Paid',NULL,NULL,NULL,NULL,NULL);
						INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
						VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Loan','LoandData',JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						IF(SCOPE_IDENTITY()<0)
						BEGIN
						  return;
						END
						ELSE
						BEGIN 
						 SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
						END
						INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
						VALUES (@Insertedfinancetransactionlid,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=@Insertedcustomeraccountid)),@EMI,CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						
						SET @i = 1;
						WHILE @i <= @n
						BEGIN
							-- Calculate the interest component for this payment
							SET @InterestPaid  = @Balance * @r;
							-- Calculate the principal component for this payment
							SET @PrincipalPaid = @EMI - @InterestPaid;
							  -- Ensure the remaining balance doesn't go negative
							IF (@Balance - @PrincipalPaid) < 0
							BEGIN
								SET @PrincipalPaid = @Balance;
								SET @InterestPaid = @EMI - @PrincipalPaid;
							END
							-- Calculate the remaining balance after this payment
							SET @Balance = @Balance - @PrincipalPaid;


							INSERT INTO Systemloandetailitems(Loandetailid,Customerid,Period,Paymentdate,Paymentamount,Currentbalance,Interestamount,Principalamount,Paymentstatus,Payementreason,Extra1,Extra2,Extra3,Extra4,Extra5)
							VALUES (@Insertedloandetailid,CAST(JSON_VALUE(@JsonObjectdata, '$.Customerid') AS BIGINT),@i + 1,DATEADD(WEEK, @i, CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2)),@EMI,@Balance,@InterestPaid,@PrincipalPaid,2,'Not Paid',NULL,NULL,NULL,NULL,NULL);
							INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
							VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Loan','LoandData',JSON_VALUE(@JsonObjectdata, '$.Createdby'),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
							IF(SCOPE_IDENTITY()<0)
							BEGIN
							  return;
							END
							ELSE
							BEGIN 
							 SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
							END
							INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
							VALUES (@Insertedfinancetransactionlid,(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =(SELECT CONVERT(VARCHAR(10),AccountNumber) FROM CustomerAccount WHERE AccountId=@Insertedcustomeraccountid)),@EMI,CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2),CAST(JSON_VALUE(@JsonObjectdata, '$.Datemodified') AS datetime2));
						
							SET @i = @i + 1;
						END
					END
    
				
				Set @RespMsg ='Loan Details Saved Successfully.'
				Set @RespStat =0; 
		
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