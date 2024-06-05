CREATE PROCEDURE [dbo].[Usp_GetSystemStaffStation]
@Userid BIGINT
AS
BEGIN
SET NOCOUNT ON;
   SELECT B.StationId,B.Sname AS StationName FROM LnkStaffStation A  INNER JOIN SystemStations B ON A.StationId=B.Tenantstationid WHERE A.UserId=@Userid
END