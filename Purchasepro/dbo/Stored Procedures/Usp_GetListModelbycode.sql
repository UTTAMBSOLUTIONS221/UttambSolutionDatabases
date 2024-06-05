CREATE PROCEDURE [dbo].[Usp_GetListModelbycode]
@Type int,
@Code BIGINT
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 5)
Select r.Vehiclemodelname as Text, r.Vehiclemodelid as Value From Systemvehiclemodels r WHERE r.Vehiclemakeid=@Code;
END