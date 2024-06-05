CREATE PROCEDURE [dbo].[Usp_Getsystemstationshifttopupdata]
@ShiftId BIGINT,
@start INT,
@length INT,
@searchParam VARCHAR(100),
@DataTableData NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET @DataTableData=(
		SELECT COUNT(ISNULL(SCC.ShiftTopupId,0)) AS RecordsTotal,(SELECT STP.ShiftTopupId,STP.ShiftId,STP.AttendantId,SST.FirstName +' '+SST.LastName AS AttendantName,STP.TopupAmount,STP.TopupReference,STP.IsReversed,STP.Createdby,STP.Modifiedby,STP.DateCreated,STP.DateModified
        FROM ShiftTopup STP
		INNER JOIN Stationshifts SS ON STP.ShiftId=SS.ShiftId
		INNER JOIN SystemStaffs SST  ON STP.AttendantId=SST.UserId
		WHERE STP.ShiftId=SCC.ShiftId
		ORDER BY STP.ShiftTopupId DESC 
		OFFSET @start ROWS FETCH NEXT @length ROWS ONLY
		FOR JSON PATH
		) AS DataTableData
		FROM ShiftTopup SCC  
		WHERE SCC.ShiftId=@ShiftId 
		GROUP BY SCC.ShiftId
		FOR JSON PATH, INCLUDE_NULL_VALUES , WITHOUT_ARRAY_WRAPPER
	)
END