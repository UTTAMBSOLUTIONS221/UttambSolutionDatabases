CREATE PROCEDURE [dbo].[Usp_GetListModelbycode]
@Type int,
@Code BIGINT
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 8)
Select r.CategoryName as Text, r.Categoryid as Value From ProductCategory r WHERE r.ParentId=@Code;
If(@Type = 9)
Select r.Uomname as Text, r.UomId as Value From Productuom r WHERE r.ParentId=@Code;
END
