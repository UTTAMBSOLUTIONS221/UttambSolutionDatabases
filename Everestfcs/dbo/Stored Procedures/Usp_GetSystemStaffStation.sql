CREATE PROCEDURE [dbo].[Usp_GetSystemStaffStation]
@Userid BIGINT
AS
BEGIN
SET NOCOUNT ON;
   SELECT B.StationId,B.Sname AS StationName,B.Extra FROM LnkStaffStation A  INNER JOIN SystemStations B ON A.StationId=B.StationId WHERE A.UserId=@Userid
END
