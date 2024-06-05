CREATE PROCEDURE [dbo].[Usp_GetListModel]
@Type int
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 1)
Select r.Rolename as Text, r.RoleId as Value From SystemRoles r;
If(@Type = 2)
Select r.Permissionname as Text, r.permissionId as Value From Systempermissions r;
If(@Type = 3)
Select r.CategoryName as Text, r.Categoryid as Value From ProductCategory r WHERE r.ParentId=0;
If(@Type = 4)
Select r.Brandname as Text, r.BrandId as Value From Productbrand r;
If(@Type = 5)
Select r.Uomname as Text, r.UomId as Value From Productuom r WHERE r.ParentId=0;
If(@Type = 6)
Select r.Productname as Text, r.SystemproductId as Value From SystemProduct r;
If(@Type = 7)
Select r.Codename as Text, r.Phoneid as Value From SystemPhonecodes r;
If(@Type = 10)
Select r.Pagename as Text, r.PageId as Value From SocialPesaFacebookPages r;
If(@Type = 11)
Select r.CategoryGroupName as Text, r.CategoryGroupId as Value From Productcategorygroup r;
If(@Type = 12)
Select r.ModuleName as Text, r.ModuleId as Value From SystemModules r;
If(@Type = 13)
Select r.BlogCategoryName as Text, r.BlogCategoryId as Value From BlogCategory r;
END