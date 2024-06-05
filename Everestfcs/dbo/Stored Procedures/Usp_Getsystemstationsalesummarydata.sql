
CREATE PROCEDURE [dbo].[Usp_Getsystemstationsalesummarydata]
    @StationId BIGINT,
    @ShiftId BIGINT,
	@StartDate DATETIME,
	@EndDate DATETIME,
	@SystemStationSaleSummaryData NVARCHAR(MAX) OUTPUT
AS
BEGIN
   BEGIN
	DECLARE 
			@RespStat int = 0,
			@RespMsg varchar(150) = 'Success';
			BEGIN
	
		BEGIN TRY
		--validate	

		
		BEGIN TRANSACTION;	
		SET @SystemStationSaleSummaryData= 
		(
		  SELECT (
			  SELECT SP.PumpName+'-'+PN.Nozzle+'-'+PV.ProductVariationName AS Nozzle,PV.ProductVariationName,SSD.OpeningRead AS OpeningReading,SSD.ClosingRead  AS ClosingReading,(SSD.ClosingRead-SSD.OpeningRead)  AS GrossSale,SSD.ProductPrice AS PricePerLiter,
			  ((SSD.ClosingRead-SSD.OpeningRead) * SSD.ProductPrice)  AS EquiCashGross,0  AS Transfers,SSD.TestingQuantity AS PumpTestRTT,SSD.GeneratorQuantity AS GeneratorFuel,(SSD.TestingQuantity+SSD.GeneratorQuantity)  AS TotalTransferRttandGen,((SSD.TestingQuantity+SSD.GeneratorQuantity) * SSD.ProductPrice)  AS EquiCashTransferRttandGen, (((SSD.ClosingRead-SSD.OpeningRead) * SSD.ProductPrice)-((SSD.TestingQuantity+SSD.GeneratorQuantity) * SSD.ProductPrice)) AS NetSale,(((SSD.ClosingRead-SSD.OpeningRead) * SSD.ProductPrice)-((SSD.TestingQuantity+SSD.GeneratorQuantity) * SSD.ProductPrice))   AS EquiCashNetSale
			  FROM StationshiftsData SSD
			  INNER JOIN Stationpumps SP ON SSD.PumpId=SP.PumpId
			  INNER JOIN PumpNozzles PN ON SSD.NozzleId=PN.NozzleId
			  INNER JOIN SystemProductvariation PV ON SSD.ProductVariationId=PV.ProductVariationId
			  INNER JOIN SystemStaffs CB ON SSD.Createdby = CB.UserId
			  INNER JOIN SystemStaffs MB ON SSD.Createdby = MB.UserId
			  WHERE (SSD.ShiftId=@ShiftId OR @ShiftId=0) AND SP.StationId=@StationId
			  FOR JSON PATH
			 ) AS ManualPumpSummary,
			 (  
			    SELECT ST.Name AS Tank,ISNULL(SUM(AA.OpeningRead),0) AS OpeningStock,ISNULL(SPIC.PurchaseQuantity,0) AS Purchases,
				ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0) AS TotalStock,(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0))AS SalebyPump,
				(ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0))) AS ExpectedClosingStock,
				(ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0))) AS ActualClosingStock,
				((ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0))) AS SaleByTank,
				((ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0)))-(ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0)))) AS Gain,
				((((ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0)))-(ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0)))) * 100.0) / (ISNULL(SUM(AA.OpeningRead),0)+ISNULL(SPIC.PurchaseQuantity,0)-(ISNULL(SUM(AA.ClosingRead),0)-ISNULL(SUM(AA.OpeningRead),0)))) AS PercentageGain
				FROM StationshiftsData AA
				INNER JOIN Stationshifts BB ON AA.ShiftId=BB.ShiftId
				INNER JOIN Stationpumps SP ON AA.PumpId=SP.PumpId
				INNER JOIN Stationtanks ST ON SP.TankId=ST.TankId
				LEFT JOIN StationPurchaseItems SPIC ON SPIC.Productvariationid = AA.Productvariationid
				WHERE (AA.ShiftId=@ShiftId OR @ShiftId=0) AND BB.StationId=@StationId
				GROUP BY ST.Name,AA.ProductvariationId,SPIC.PurchaseQuantity
			    FOR JSON PATH
			   ) AS ManualTankSummary
		 FOR JSON PATH, INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER
		);

	    Set @RespMsg ='Success'
		Set @RespStat =0; 
		COMMIT TRANSACTION;

		SELECT  @RespStat as RespStatus, @RespMsg as RespMessage,@SystemStationSaleSummaryData as SystemStationSaleSummaryData;

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