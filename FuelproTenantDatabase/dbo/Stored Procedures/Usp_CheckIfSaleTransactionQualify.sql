CREATE PROCEDURE [dbo].[Usp_CheckIfSaleTransactionQualify]
@JsonObjectdata VARCHAR(MAX),@FinanceTransactionId BIGINT 
AS
BEGIN
   BEGIN
	DECLARE 
	@RespStat int = 0,
	@RespMsg varchar(150) = '',
	@LraDatainputId BIGINT,
	@ProductvariationId BIGINT=0,
	@AccountId BIGINT,
	@LSchemeRuleId BIGINT = 0,
	@CollisionRule VARCHAR(10),
	@TransactionAwardingType varchar(10) = '',
	@ResultAmount DECIMAL(34,5) = 0,
	@CustomValidationCount BIGINT = 0, 
	@ValidationRuleCount BIGINT = 0,
	@amount DECIMAL(34,5) = 0,
	@quantity DECIMAL(34,5) = 0,
	@price DECIMAL(34,5) = 0,
	@finalRewardAmount BIGINT=0,
	@output decimal(18,5) = 0, 
	
	@formula decimal(18,5) = 0,
	@vtype varchar(10) = 0, 
	@wOrd varchar(10)='', 
	@roundNumber int = 0, 
	@cOrf varchar(10)='';

	CREATE TABLE #ValidationResults (LSchemeRuleId BIGINT,Updated BIT, Amount DECIMAL(34,2),RuleName VARCHAR(50), IsPassed BIT);
	CREATE TABLE #Productvariationdata (productvariationUnits DECIMAL(34,2),productVariationPrice DECIMAL(34,2), Amount DECIMAL(34,2));
	BEGIN
		DECLARE @SchemeIdList TABLE (SchemeId INT);
         INSERT INTO @SchemeIdList (SchemeId)
           
		 SELECT DISTINCT LSchemeRuleId FROM LSchemeRules;
		 INSERT INTO LRADataInputs(FinanceTransactionId,GroupingId,AccountId,StationId,TransactionDate,TransactionTime,TransactionDay,IsProcessed,IsRejected,RejectReason,IsActive,IsDeleted,Createdby,Modifiedby,DateCreated ,DateModified)
			(SELECT @FinanceTransactionId,(SELECT  GroupingId from Customeraccount WHERE  AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')),JSON_VALUE(@JsonObjectdata, '$.AccountId'),JSON_VALUE(@JsonObjectdata, '$.StationId'),cast(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') as date),cast(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') as time),(SELECT DATENAME(dw,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),0,0,NULL,1,0,
			JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)));

			SET @LraDataInputId = SCOPE_IDENTITY();

		 WHILE EXISTS (SELECT 1 FROM @SchemeIdList)
            BEGIN
                -- Get the first scheme in the list
                SELECT TOP 1 @LSchemeRuleId = SchemeId  FROM @SchemeIdList;
                -- Continue with other validation checks
					--Validate
					 --Validate Products 
					IF NOT EXISTS(SELECT LSRuleProductId FROM LsRuleProducts WHERE ProductvariationId IN(SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)) AND LSchemeRuleId= @LSchemeRuleId)
					 BEGIN 
						 Select  0 as RespStatus, 'Product Not in the List' as RespMessage;
						 UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Product Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END

					  --Validate Payment 
					IF NOT EXISTS(SELECT LSRulePaymentModeId FROM LsRulePaymentmodes WHERE PaymentModeId IN(SELECT paymentModeId FROM OPENJSON (@JsonObjectdata, '$.PaymentList') WITH (PaymentModeId BIGINT)) AND LSchemeRuleId= @LSchemeRuleId)
					 BEGIN 
						 Select  0 as RespStatus, 'Payment Mode Not in the List' as RespMessage;
						 UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Payment Mode Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END

					--Validate Outlet 
					IF NOT EXISTS(SELECT LSRuleStationId FROM LsRulestations WHERE StationId=JSON_VALUE(@JsonObjectdata, '$.StationId') AND LSchemeRuleId= @LSchemeRuleId)
					 BEGIN 
						 Select  0 as RespStatus, 'Outlet Not in the List' as RespMessage;
						  UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Outlet Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END
					 --Validate Grouping 
					IF NOT EXISTS(SELECT LSRuleGroupingId FROM LsRuleLoyaltyGrouping WHERE GroupingId=(SELECT  GroupingId from Customeraccount WHERE  AccountId=JSON_VALUE(@JsonObjectdata, '$.AccountId')) AND LSchemeRuleId= @LSchemeRuleId)
					 BEGIN 
						 Select  0 as RespStatus, 'Loyalty Group Not in the List' as RespMessage;
						 UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Loyalty Group Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END

					--Validate Time 
					IF NOT EXISTS(SELECT LSRuleTimeId FROM LsRuleTimes WHERE cast(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') as time) >= StartTime AND  cast(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') as time)< EndTime AND LSchemeRuleId= @LSchemeRuleId)
					 BEGIN 
						 Select  0 as RespStatus, 'Time Not in the List' as RespMessage;
						 UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Time Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END

					 --Validate transaction day 
					IF NOT EXISTS(SELECT LSRuleDayId FROM lsruledays WHERE LSchemeRuleId= @LSchemeRuleId AND CHARINDEX(UPPER(DATENAME(dw, TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.TransactionDate') AS datetime2(6)))),UPPER(DaysofWeek)) > 0)
					 BEGIN 
						 Select  0 as RespStatus, 'Day Not in the List' as RespMessage;
						 UPDATE LRADataInputs SET IsRejected=1,RejectReason = 'Day Not in the List' WHERE LRADataInputId = @LraDataInputId
						 return;
					 END

                -- If all checks pass, set the response status and message
                -- For example, if all checks pass, set @RespStat = 0 and @RespMsg = 'Success'

				 INSERT INTO #Productvariationdata (productvariationUnits,productVariationPrice, Amount)
				(SELECT productvariationUnits,productVariationPrice, (productvariationUnits * productVariationPrice) AS Amount FROM OPENJSON(@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId INT '$.ProductVariationId', ProductvariationUnits DECIMAL(18,2), ProductVariationPrice DECIMAL(18,2))WHERE ProductVariationId IN (SELECT ProductvariationId FROM LsRuleProducts WHERE ProductvariationId IN(SELECT ProductVariationId FROM OPENJSON (@JsonObjectdata, '$.TicketLines') WITH (ProductVariationId BIGINT)) AND LSchemeRuleId= @LSchemeRuleId));

				SET @quantity = (SELECT SUM(productvariationUnits) FROM #Productvariationdata);
				SET @amount = (SELECT SUM(Amount) FROM #Productvariationdata);

                -- Insert the results into the #ValidationResults table
                INSERT INTO #ValidationResults (LSchemeRuleId,Updated, Amount, RuleName, IsPassed)
                VALUES ((SELECT TOP 1 Formulaid FROM LSchemeRules WHERE LSchemeRuleId = @LSchemeRuleId),0,@ResultAmount, 'Scheme Rule Validation', 1);

                -- Remove the processed scheme from the list
                DELETE FROM @SchemeIdList WHERE SchemeId = @LSchemeRuleId;
            END;
			
			  -- Finally, return the validation results
           SET @ValidationRuleCount =  (SELECT COUNT(LSchemeRuleId) FROM #ValidationResults);
           SET @CollisionRule = (SELECT TOP 1 collisionRule FROM loyaltySettings);

		   WHILE @CustomValidationCount < @ValidationRuleCount
		   BEGIN
		        SET  @LSchemeRuleId = (SELECT TOP 1 LSchemeRuleId FROM #ValidationResults WHERE Updated = 0); 
	            SELECT TOP 1 @TransactionAwardingType= ValueType FROM LFormulas WHERE  FormulaId = (SELECT TOP 1 Formulaid FROM LSchemeRules WHERE LSchemeRuleId = @LSchemeRuleId);

				SELECT (CAST(SUBSTRING(LFR.Formula, 9, LEN(LFR.Formula)) AS DECIMAL(18,2))) AS WHO,LFR.Range1, LFR.Range2, LFR.IsRangetoInfinity,LF.ValueType as CASNEB,LR.isWholeOrDecimal,LR.IsDecimalRoundOfNumber,LR.isWholeCeilOrFloor into #test 
				 FROM  LFormulaRules LFR 
				 LEFT JOIN LFormulas LF ON LFR.FormulaId = LF.FormulaId 
				 LEFT JOIN LSchemeRules LSR ON LSR.FormulaId = LFR.FormulaId
				 LEFT JOIN LRewards LR ON LR.LRewardId = LSR.LRewardId
				 WHERE  LFR.IsApproved = 1 and LSR.LSchemeRuleId =  @LSchemeRuleId;

				IF(@TransactionAwardingType='Amount')
					BEGIN
						select top 1 @output=(WHO * @amount),@wOrd=isWholeOrDecimal,@roundNumber = IsDecimalRoundOfNumber,@cOrf=isWholeCeilOrFloor from #test where (@amount > Range1 and @amount <= Range2) or IsRangetoInfinity = 1 order by Range1;
						IF(@wOrd='Decimal') 
							BEGIN 
							SET @output = round(@output,@roundNumber); 
							END 
						ELSE IF(@wOrd='Whole') 
							BEGIN  
							IF(@cOrf='Up') 
									BEGIN 
									SET @output = ceiling(@output); 
									END
							ELSE 
								BEGIN
									SET @output = floor(@output);
								END
							END
						END
					ELSE
					BEGIN
						select top 1 @output=(WHO * @quantity),@wOrd=isWholeOrDecimal,@roundNumber = IsDecimalRoundOfNumber,@cOrf=isWholeCeilOrFloor from #test where (@quantity > Range1 and @quantity <= Range2) or IsRangetoInfinity = 1 order by Range1;
						IF(@wOrd='Decimal')
							BEGIN 
								SET @output = round(@output,@roundNumber); 
							END
							ELSE IF(@wOrd='Whole') 
								BEGIN  
								IF(@cOrf='Up') 
									BEGIN 
										SET @output = ceiling(@output); 
									END 
								ELSE 
									BEGIN 
									SET @output = floor(@output);
									END
							END
						END
						drop table #test;
						update  #ValidationResults set Updated = 1, Amount = @output where LSchemeRuleId = @LSchemeRuleId;
						SET @CustomValidationCount = @CustomValidationCount + 1;
					END
			 IF(@CollisionRule='SUM')
			   BEGIN
			     --Insert into results table
				   INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
				   VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Points'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Award'),
				   @LraDataInputId,0,(SELECT SUM(Amount) AS rewardAmount FROM #ValidationResults),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
				   UPDATE LRADataInputs SET IsProcessed = 1,IsRejected = 0,RejectReason = 'PROC' WHERE LRADataInputId = @LraDataInputId
			   END
			   ELSE IF(@CollisionRule='AVERAGE')
			   BEGIN
			      INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
				  VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Points'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Award'),
				   @LraDataInputId,0,(SELECT (SUM(Amount)/COUNT(*)) AS rewardAmount FROM #ValidationResults),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
			      UPDATE LRADataInputs SET IsProcessed = 1,IsRejected = 0,RejectReason = 'PROC' WHERE LRADataInputId = @LraDataInputId
			   END
			   ELSE IF(@CollisionRule='MAX')
			   BEGIN
			     INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
				  VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Points'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Award'),
				   @LraDataInputId,0,(SELECT MAX(Amount) AS rewardAmount FROM #ValidationResults),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
			      UPDATE LRADataInputs SET IsProcessed = 1,IsRejected = 0,RejectReason = 'PROC' WHERE LRADataInputId = @LraDataInputId
			   END
			   ELSE IF(@CollisionRule='MIN')
			   BEGIN
			      INSERT INTO LRResults(AccountId,LRewardId,LTransactionTypeId,LRADataInputId,LRConversionDataInputId,RewardAmount,IsActive,IsDeleted,Createdby,Modifiedby,ActualDateCreated,DateCreated,DateModified) 
				  VALUES (JSON_VALUE(@JsonObjectdata, '$.AccountId'),(SELECT LrewardId FROM Lrewards WHERE RewardName = 'Points'),(SELECT LtransactionTypeId FROM LtransactionTypes WHERE LtransactionTypeName = 'Award'),
				   @LraDataInputId,0,(SELECT MIN(Amount) AS rewardAmount FROM #ValidationResults),1,0,JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),JSON_VALUE(@JsonObjectdata, '$.CreatedbyId'),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)),TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Datecreated') AS datetime2(6)))
			      UPDATE LRADataInputs SET IsProcessed = 1,IsRejected = 0,RejectReason = 'PROC' WHERE LRADataInputId = @LraDataInputId
			   END
			DROP TABLE #ValidationResults;
			 DROP TABLE #Productvariationdata	 
		END
	END
END