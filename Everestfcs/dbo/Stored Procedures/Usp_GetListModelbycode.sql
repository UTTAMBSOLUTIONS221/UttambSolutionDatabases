CREATE PROCEDURE [dbo].[Usp_GetListModelbycode]
@Type int,
@Code BIGINT
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 1)
Select r.Rolename as Text, r.RoleId as Value From Systemroles r WHERE  r.TenantId=@Code AND r.Isdefault =0;
If(@Type = 3)
Select r.Sname as Text, r.StationId as Value From SystemStations r WHERE r.TenantId=@Code;
If(@Type = 5)
Select r.PriceListname as Text, r.PriceListId as Value From PriceList r WHERE r.TenantId=@Code;
If(@Type =6)
Select r.DiscountListname as Text, r.DiscountListId as Value From DiscountList r WHERE r.TenantId=@Code;
If(@Type =11)
Select r.Productvariationname as Text, r.ProductvariationId as Value,PC.CategoryId AS GroupId,PC.Categoryname AS GroupName From SystemProductvariation r INNER JOIN SystemProduct t ON r.ProductId=t.ProductId INNER JOIN Productcategory PC ON t.CategoryId=PC.CategoryId  WHERE t.TenantId=@Code;
If(@Type =14)
Select r.FormulaName as Text, r.FormulaId as Value From LFormulas r WHERE r.TenantId=@Code;
If(@Type = 19)
Select r.Name as Text, r.Tankid as Value  From StationTanks r WHERE r.Stationid=@Code;
If(@Type = 20)
Select CASE WHEN r.Designation='Corporate' THEN r.Companyname ELSE r.Firstname+' '+ r.Lastname END as Text, r.CustomerId as Value From Customers r WHERE r.TenantId=@Code;
If(@Type = 21)
Select r.Firstname+' '+r.Lastname as Text, r.Userid as Value From SystemStaffs r LEFT JOIN LnkStaffStation b ON r.Userid=b.UserId WHERE b.StationId=@code;
If(@Type = 22)
Select r.EquipmentModel as Text, r.EquipmentModelId as Value From EquipmentModels r WHERE r.EquipmentMakeId=@Code;
If(@Type = 23)
Select r.CardSNO as Text, r.CardId as Value From Systemcard r WHERE r.TagtypeId=@Code AND r.Isassigned=0;
If(@Type = 24)
 SELECT ca.AccountId as Value,cc.CardSNO as Text FROM CustomerAccount ca INNER JOIN SystemAccountCards cb ON cb.AccountId=ca.AccountId INNER JOIN Systemcard cc ON cb.CardId=cc.CardId WHERE ca.Parentid=@Code AND ca.Isactive=1 AND ca.Isdeleted=0;
If(@Type = 25)
 SELECT ca.AccountId as Value,cc.CardSNO as Text FROM CustomerAccount ca INNER JOIN SystemAccountCards cb ON cb.AccountId=ca.AccountId INNER JOIN Systemcard cc ON cb.CardId=cc.CardId WHERE ca.Parentid=(SELECT ParentId FROM CustomerAccount where AccountId=@Code) AND ca.Isactive=1 AND ca.Isdeleted=0 AND ca.ParentId!=0 AND ca.AccountId!=@Code;
If(@Type = 26)
 SELECT ca.AgreementId as Value,ta.Agreementtypename as Text FROM CustomerAgreements ca INNER JOIN AgreementTypes ta ON ca.AgreemettypeId=ta.AgreemettypeId  WHERE  ca.CustomerId=@Code AND ca.Isactive=1 AND ca.Isdeleted=0;
If(@Type = 27)
 SELECT ca.AccountId as Value,CONVERT(VARCHAR(20),ca.AccountNumber) +' - '+  sc.CardSNO as Text FROM CustomerAccount ca INNER JOIN SystemAccountCards sac ON ca.AccountId=sac.AccountId INNER JOIN Systemcard sc ON sac.CardId=sc.CardId WHERE ca.AgreementId=@Code AND ca.Isactive=1 AND ca.Isdeleted=0;
If(@Type =30)
Select r.Pumpname as Text, r.Pumpid as Value From Stationpumps r INNER JOIN SystemStations t ON r.Stationid=t.StationId WHERE t.StationId=@code;
If(@Type =31)
Select b.Productvariationname as Text, b.ProductVariationId as Value from PriceListprices a INNER JOIN SystemProductvariation b ON a.ProductVariationId=b.ProductVariationId  INNER JOIN SystemProduct c ON b.ProductId=c.ProductId  WHERE a.StationId=@code AND c.CategoryId IN (SELECT CategoryId FROM ProductCategory WHERE Categoryname  IN('Spare Parts','Lubricants','LPG and Accessories'))
If(@Type =32)
SELECT CASE WHEN Designation='Corporate' THEN C.Companyname ELSE C.Firstname+' '+ C.Lastname END as Text, C.CustomerId as Value  FROM CustomerAgreements A INNER JOIN AgreementTypes ATP ON A.AgreemettypeId=ATP.AgreemettypeId INNER JOIN Customers C ON A.CustomerId=C.CustomerId WHERE ATP.Agreementtypename !='Prepaid-Agreement' AND C.TenantId=@code
If(@Type =33)
SELECT A.EquipmentRegNo as Text, A.Equipmentid as Value FROM CustomerEquipments A INNER JOIN AccountEquipments B ON A.EquipmentId=B.EquipmentId INNER JOIN CustomerAccount C ON B.AccountId=C.AccountId INNER JOIN CustomerAgreements D ON C.AgreementId=D.AgreementId INNER JOIN Customers E ON D.CustomerId=E.CustomerId WHERE E.CustomerId =@code
If(@Type =34)
Select r.SupplierName as Text, r.SupplierId as Value From SystemSuppliers r WHERE r.TenantId=@Code;
If(@Type =35)
Select r.ShiftCode as Text, r.ShiftId as Value From StationShifts r WHERE r.StationId=@Code;
If(@Type =36)
Select r.Productvariationname as Text, r.ProductvariationId as Value From SystemProductvariation r INNER JOIN SystemProduct t ON r.ProductId=t.ProductId WHERE t.TenantId=@Code AND T.CategoryId IN (SELECT CategoryId FROM Productcategory  WHERE Categoryname='Fuel(Petrol, Diesel,Kerosine)');
END
