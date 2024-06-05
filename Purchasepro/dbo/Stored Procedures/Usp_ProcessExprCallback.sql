CREATE PROCEDURE [dbo].[Usp_ProcessExprCallback]
	@ServiceCode int,
	@OrgRef varchar(50),
	@Receiver Varchar(50),
	@ResultCode Varchar(10),
	@ResultDescr Varchar(250),
	@TxnID Varchar(15),
	@Amount decimal(12,2)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @RespStat INT = 0,
			@RespMsg VARCHAR(150) = '',
			@ClientUrl  VARCHAR(200) = '',
			@PaymentRef VARCHAR(20) = '',
			@ServiceNo VARCHAR(20),
			@Createdby INT  =0,
			@Paymentmemo VARCHAR(700)= '',
			@AccountNo VARCHAR(20),
			@Phonenumber VARCHAR(20),
			@PAmount DECIMAL(12,2),
			@Id INT,
			@Stat INT,
			@PType INT,
			@PService INT,
			@Insertedfinancetransactionlid BIGINT,
		    @remainingMoney DECIMAL(18, 2);
           
		


    BEGIN TRY
		--- Validate service
	   SET @remainingMoney = @Amount;
		---- Get payment
		Select	@Id = Paymentid, @Stat = PStatus, @PType = PType, @PService = ServiceCode, @PaymentRef = PaymentRef, @AccountNo = Extra1,@Phonenumber=AccountNo ,@Paymentmemo = Extra2,@Createdby = Extra3,@PAmount = Amount From Payments Where ExtRef = @OrgRef

		---- Validate Service
		If(@Stat Is Null)
		Begin
			Select 1 as RespStatus, 'Failed to trace the payment record!' as RespMessage	
			Return
		End
		If(@PService <> @ServiceCode)
		Begin
			Select 1 as RespStatus, 'Originating service failed check!' as RespMessage	
			Return
		End
		If(@PType <> 3)
		Begin
			Select 1 as RespStatus, 'Operation not allowed for this type of payment!' as RespMessage	
			Return
		End
		--If(@Amount <> @PAmount)
		--Begin
		--	Select 1 as RespStatus, 'Failed due to amount mismatch!' as RespMessage	
		--	Return
		--End
		
	BEGIN
		BEGIN TRY
		  BEGIN TRANSACTION
		    WHILE @remainingMoney > 0
				  BEGIN
					DECLARE @nextInvoiceID INT;
					DECLARE @nextInvoiceAmount DECIMAL(18, 2);
					SELECT TOP 1  @nextInvoiceID = c.LoanDetailItemId,  @nextInvoiceAmount = (c.Paymentamount - ISNULL(d.Recievedamount, 0)) 
					FROM Systemloandetail a 
					INNER JOIN Systemassetdetail b ON a.Assetdetailid = b.Assetdetailid 
					INNER JOIN Systemloandetailitems c ON a.Loandetailid = c.Loandetailid 
					LEFT JOIN Systemloanitempayments d ON c.LoanDetailItemId = d.LoanDetailItemId 
					INNER JOIN Loanidaccountid e ON a.Loandetailid = e.Loandetailid
					WHERE c.Paymentstatus != 0 AND b.Assetnumber = @AccountNo ORDER BY c.Paymentdate

					 IF @nextInvoiceID IS NULL
									BREAK;
					IF @nextInvoiceAmount <= @remainingMoney
					BEGIN
					--IF @OrgRef IS NULL
					--BEGIN
					--   SET @OrgRef
					--END


					
					   INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
							VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Payment',@Paymentmemo,CONVERT(INT,@Createdby),(SELECT Paymentdate FROM Systemloandetailitems WHERE Loandetailitemid=@nextInvoiceID),GETDATE());
							IF(SCOPE_IDENTITY()<0)
							BEGIN
								return;
							END
							ELSE
							BEGIN 
								SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
							END

							INSERT INTO Systemloanitempayments(FinanceTransactionId,AccountId,Loandetailitemid,Paymentamount,Recievedamount,ModeofPayment,Paymentmemo,Topupreference,Topupreferencecode,Createdby,Datecreated)
							SELECT @Insertedfinancetransactionlid,
							(SELECT e.Accountid FROM Systemloandetailitems a 
							INNER JOIN Systemloandetail b ON a.Loandetailid = b.Loandetailid 
							INNER JOIN Systemassetdetail c ON b.Assetdetailid = c.Assetdetailid 
							INNER JOIN Loanidaccountid e ON a.Loandetailid = e.Loandetailid 
							INNER JOIN CustomerAccount f ON e.Accountid = f.Accountid 
							WHERE a.Loandetailitemid=@nextInvoiceID),@nextInvoiceID,@nextInvoiceAmount,@nextInvoiceAmount,'Mpesa',@Paymentmemo,@Phonenumber,@TxnID,CONVERT(INT,@Createdby),GETDATE()

							INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
							VALUES (@Insertedfinancetransactionlid,
							(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(10),(SELECT f.AccountNumber FROM Systemloandetailitems a 
							INNER JOIN Systemloandetail b ON a.Loandetailid = b.Loandetailid 
							INNER JOIN Systemassetdetail c ON b.Assetdetailid = c.Assetdetailid 
							INNER JOIN Loanidaccountid e ON a.Loandetailid = e.Loandetailid 
							INNER JOIN CustomerAccount f ON e.Accountid = f.Accountid 
							WHERE a.Loandetailitemid=@nextInvoiceID))),
							-1* @nextInvoiceAmount,
							(SELECT Paymentdate FROM Systemloandetailitems WHERE Loandetailitemid=@nextInvoiceID),GETDATE());
							UPDATE Systemloandetailitems SET Paymentstatus =0,Payementreason='Fully Paid' WHERE Loandetailitemid=@nextInvoiceID
						   SET @remainingMoney -= @nextInvoiceAmount;
					END
					ELSE
					BEGIN
						INSERT INTO FinanceTransactions(TransactionCode,ParentId,Saledescription,SaleRefence,Createdby,ActualDate,DateCreated)
							VALUES ('TXN'+''+CONVERT(VARCHAR(70),NEXT VALUE FOR TransactionCodeSequence),0,'Payment',@Paymentmemo,@Createdby,(SELECT Paymentdate FROM Systemloandetailitems WHERE Loandetailitemid=@nextInvoiceID),GETDATE());
					
							IF(SCOPE_IDENTITY()<0)
							BEGIN
								return;
							END
							ELSE
							BEGIN 
								SET @Insertedfinancetransactionlid=SCOPE_IDENTITY();
							END

							INSERT INTO Systemloanitempayments(FinanceTransactionId,AccountId,Loandetailitemid,Paymentamount,Recievedamount,ModeofPayment,Paymentmemo,Topupreference,Topupreferencecode,Createdby,Datecreated)
							SELECT @Insertedfinancetransactionlid,
							(SELECT e.Accountid FROM Systemloandetailitems a 
							INNER JOIN Systemloandetail b ON a.Loandetailid = b.Loandetailid 
							INNER JOIN Systemassetdetail c ON b.Assetdetailid = c.Assetdetailid 
							INNER JOIN Loanidaccountid e ON a.Loandetailid = e.Loandetailid 
							INNER JOIN CustomerAccount f ON e.Accountid = f.Accountid 
							WHERE a.Loandetailitemid=@nextInvoiceID),@nextInvoiceID,(SELECT Paymentamount FROM Systemloandetailitems WHERE Loandetailitemid=@nextInvoiceID),@remainingMoney,'Mpesa',@Paymentmemo,@Phonenumber,@TxnID,CONVERT(INT,@Createdby),GETDATE()

							INSERT INTO GLTransactions(FinanceTransactionId,ChartofAccountId,Amount,GlActualDate,DateCreated)
							VALUES (@Insertedfinancetransactionlid,
							(SELECT ChartofAccountId FROM ChartofAccounts WHERE ChartofAccountname =CONVERT(VARCHAR(10),(SELECT f.AccountNumber FROM Systemloandetailitems a 
							INNER JOIN Systemloandetail b ON a.Loandetailid = b.Loandetailid 
							INNER JOIN Systemassetdetail c ON b.Assetdetailid = c.Assetdetailid 
							INNER JOIN Loanidaccountid e ON a.Loandetailid = e.Loandetailid 
							INNER JOIN CustomerAccount f ON e.Accountid = f.Accountid 
							WHERE a.Loandetailitemid=@nextInvoiceID))),
							-1* @remainingMoney,
							(SELECT Paymentdate FROM Systemloandetailitems WHERE Loandetailitemid=@nextInvoiceID),GETDATE());

							UPDATE Systemloandetailitems SET Paymentstatus =1,Payementreason='Partially Paid' WHERE Loandetailitemid=@nextInvoiceID

					 BREAK;
					END
				  END


				--- Update record now
				Update Payments Set RespNo = @ResultCode, RespMsg = (Case when @ResultCode = '0' Then '' Else @ResultDescr End), ExtRef = @TxnID,PStatus =(Case when @ResultCode = '0' Then 2 Else 3 End),AccountName = @Receiver Where Paymentid = @Id
			COMMIT TRANSACTION
				--- Create response
				SELECT	@RespStat as RespStatus, @RespMsg as RespMessage,@ClientUrl as Data1,@PaymentRef as Data2,@ServiceNo as Data3,@AccountNo as Data4, @nextInvoiceID AS Data5
				END TRY
				BEGIN CATCH
					ROLLBACK TRANSACTION
					PRINT 'Payment for Invoice ' + CAST(@nextInvoiceID AS NVARCHAR(10)) + ' failed. Transaction rolled back.'
					PRINT 'Error ' + error_message();
		            Select 2 as RespStatus, '0 - Error(s) Occurred' + error_message() as RespMessage
				END CATCH
			END
	END TRY
	BEGIN CATCH
		SELECT @RespMsg = ERROR_MESSAGE(), @RespStat = 2;	
		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage	
	END CATCH	
END