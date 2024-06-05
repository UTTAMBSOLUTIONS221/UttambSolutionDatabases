CREATE PROCEDURE [dbo].[Usp_GetListModel]
@Type int
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 1)
Select r.Rolename as Text, r.RoleId as Value From SystemRoles r WHERE r.IsDefault =0;
If(@Type = 2)
Select r.Groupingname as Text, r.GroupingId as Value From LoyaltyGroupings r;
If(@Type = 3)
Select r.Sname as Text, r.Tenantstationid as Value From SystemStations r;
If(@Type = 4)
Select r.Countryname as Text, r.CountryId as Value From SystemCountry r;
If(@Type = 5)
Select r.PriceListname as Text, r.PriceListId as Value From PriceList r;
If(@Type =6)
Select r.DiscountListname as Text, r.DiscountListId as Value From DiscountList r;
If(@Type =7)
Select r.LimitTypename as Text, r.LimitTypeId as Value From ConsumLimitType r;
If(@Type =8)
Select r.TagTypename as Text, r.TagtypeId as Value From Systemcardtype r WHERE r.TagTypename !='V-Card';
If(@Type =9)
Select r.Permissionname as Text, r.PermissionId as Value From SystemPerms r;
If(@Type =10)
Select r.Paymentmode as Text, r.PaymentmodeId as Value,r.PaymentmodetypeId AS GroupId,p.Paymentmodetype AS Groupname From Paymentmodes r inner join Paymentmodetypes p on r.PaymentmodetypeId=p.PaymentmodetypeId;
If(@Type =101)
Select r.Paymentmode as Text, r.PaymentmodeId as Value,r.PaymentmodetypeId AS GroupId,p.Paymentmodetype AS Groupname From Paymentmodes r inner join Paymentmodetypes p on r.PaymentmodetypeId=p.PaymentmodetypeId WHERE r.Paymentmode in('Card','Cash','Ivoucher');
--If(@Type =11)
--Select r.Agreementtypename as Text, r.AgreemettypeId as Value From AgreementTypes r where r.Agreementtypename  not in ('Prepaid Agreement') order by r.AgreemettypeId asc;
If(@Type =11)
Select r.Productvariationname as Text, r.ProductvariationId as Value From SystemProductvariation r;
If(@Type =12)
Select r.EquipmentMake as Text, r.EquipmentMakeId as Value From EquipmentMakes r;
If(@Type =13)
Select r.CurrencyName+'('+ r.CurrencySymbol+')' as Text, r.CurrencyId as Value From SystemCurrencies r;
If(@Type =14)
Select r.FormulaName as Text, r.FormulaId as Value From LFormulas r;
If(@Type =15)
Select r.RewardName as Text, r.LRewardId as Value From LRewards r;
If(@Type =16)
Select r.Codename as Text, r.Phoneid as Value From SystemPhoneCodes r;
If(@Type =17)
Select r.Categoryname as Text, r.CategoryId as Value From Productcategory r;
If(@Type =18)
Select r.Uomname as Text, r.Uomid as Value From ProductUoms r;
If(@Type =19)
Select r.Name as Text, r.Tankid as Value From Stationtanks r;
If(@Type =20)
Select (case when r.Designation='Individual' then (IsNull(r.FirstName,'')+' '+IsNull(r.LastName,'')) else r.CompanyName end) as Text, r.CustomerId as Value From Customers r;
END