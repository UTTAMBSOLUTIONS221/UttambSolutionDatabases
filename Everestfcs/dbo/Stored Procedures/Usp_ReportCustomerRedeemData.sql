CREATE PROCEDURE [dbo].[Usp_ReportCustomerRedeemData] 
	@JsonObjectdata VARCHAR(MAX) OUTPUT,
	@PointRedeemDataDetailsJson VARCHAR(MAX) OUTPUT
AS
BEGIN
 SELECT
        @PointRedeemDataDetailsJson = (
        SELECT 
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6)) AS StartDate,
            TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6)) AS EndDate,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Customer') < 1 THEN 'ALL' ELSE (SELECT RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))) FROM Customers C WHERE C.CustomerId=JSON_VALUE(@JsonObjectdata, '$.Customer')) END)AS CustomerName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Station') < 1 THEN 'ALL' ELSE (SELECT SS.Sname FROM SystemStations SS WHERE SS.StationId=JSON_VALUE(@JsonObjectdata, '$.Station')) END)AS StationName,
			(CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Account') < 1 THEN 'ALL' ELSE (SELECT CS.CardSNO FROM CustomerAccount CA INNER JOIN SystemAccountCards SC ON SC.AccountId=CA.AccountId INNER JOIN Systemcard CS ON CS.CardId=SC.CardId WHERE CA.AccountId=JSON_VALUE(@JsonObjectdata, '$.Account')) END)AS AccountName,
            (CASE WHEN JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1 THEN 'ALL' ELSE (SELECT ST.Firstname+' '+ST.LastName FROM SystemStaffs ST WHERE ST.UserId=JSON_VALUE(@JsonObjectdata, '$.Attendant')) END)AS AttendantName,
		    (
				SELECT max(R.datecreated) AS TransactionDate
					,UPPER(max(RTRIM(LTRIM(ISNULL(C.FirstName, '') + ' ' + ISNULL(C.LastName, '') + ISNULL(C.CompanyName, ''))))) AS Customer,C.IDNumber
					,(SELECT TOP 1 CardSNO FROM Systemcard Where CardId in (SELECT CardId FROM SystemAccountCards Where AccountId = (SELECT AccountId FROM CustomerAccount Where AccountId = CA.AccountId ))AND TagTypeId in (SELECT TOP 1 TagtypeId FROM Systemcardtype Where TagTypename in ('Card','Tag')) ) AS AccountNumber
					,max(LDI.ConvertToAmount) AS RedeemedAmount
					,max((
							 CASE WHEN CT.Credittypevalue = 0 THEN 'Prepaid' ELSE 'Postpaid' END
							)) AS AccountCreditType
					,max(R.RewardAmount) AS RedeemedValue
					,max(S.Sname) AS Station
					, STF.Firstname+' '+STF.LastName AS Attendant
				FROM LRResults R
				INNER JOIN CustomerAccount CA ON CA.AccountId = R.AccountId
				 INNER JOIN CreditTypes CT ON CA.CredittypeId=CT.CredittypeId
				INNER JOIN CustomerAgreements AG ON CA.AgreementId=AG.AgreementId
				INNER JOIN Customers C ON AG.AgreementId = CA.AgreementId
				INNER JOIN LRConversionDataInputs LDI ON R.LRConversionDataInputId = LDI.LRConversionDataInputId
				INNER JOIN SystemStations S ON S.Stationid = LDI.Stationid
				INNER JOIN SystemStaffs AS STF ON STF.UserId = LDI.StaffId
				WHERE (
						JSON_VALUE(@JsonObjectdata, '$.Customer') < 1
						OR C.CustomerId = JSON_VALUE(@JsonObjectdata, '$.Customer')
						)
					AND (
						JSON_VALUE(@JsonObjectdata, '$.Account') < 1
						OR CA.AccountId = JSON_VALUE(@JsonObjectdata, '$.Account')
						)
					AND R.LRewardId = (
						SELECT L.LRewardId
						FROM LRewards L
						WHERE L.RewardName = 'Points'
						)
					AND R.LTransactionTypeId = (
						SELECT LT.LTransactionTypeId
						FROM LTransactionTypes LT
						WHERE LT.LTransactionTypeName = 'Conversion'
						)
					AND R.DateCreated BETWEEN TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Startdate') AS datetime2(6))
						AND (dateadd(day,1,TRY_CAST(JSON_VALUE(@JsonObjectdata, '$.Enddate') AS datetime2(6))))
					--AND FC.TagTypeId = (SELECT Id FROM TagTypes WHERE Name = 'Card')
					AND (
						JSON_VALUE(@JsonObjectdata, '$.Station') < 1
						OR LDI.Stationid = JSON_VALUE(@JsonObjectdata, '$.Station')
						)
					AND (
						JSON_VALUE(@JsonObjectdata, '$.Attendant') < 1
						OR LDI.StaffId = JSON_VALUE(@JsonObjectdata, '$.Attendant')
						)
				GROUP BY Ca.AccountId,(LDI.LRConversionDataInputId),C.IDNumber,STF.Firstname,STF.LastName
				ORDER BY MAX(R.DATECREATED) DESC
				  FOR JSON PATH
					) AS CustomerPointRedeem
		FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
	);
END