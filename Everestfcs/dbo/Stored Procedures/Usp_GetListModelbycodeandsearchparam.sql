CREATE PROCEDURE [dbo].[Usp_GetListModelbycodeandsearchparam]
@Type int,
@Code BIGINT,
@SearchParam VARCHAR(100)
AS
BEGIN
SET NOCOUNT ON;
If(@Type =10)
Select r.Paymentmode as Text, r.PaymentmodeId as Value,r.PaymentmodetypeId AS GroupId,p.Paymentmodetype AS Groupname From Paymentmodes r inner join Paymentmodetypes p on r.PaymentmodetypeId=p.PaymentmodetypeId WHERE r.Paymentmode=@SearchParam;
If(@Type =11)
Select r.Productvariationname as Text, r.ProductvariationId as Value From SystemProductvariation r INNER JOIN SystemProduct t ON r.ProductId=t.ProductId WHERE t.TenantId=@Code AND T.CategoryId IN (SELECT CategoryId FROM Productcategory  WHERE Categoryname=@SearchParam);
END