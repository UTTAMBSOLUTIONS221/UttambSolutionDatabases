CREATE PROCEDURE [dbo].[Usp_GetListModelbycodeandtenant]
@TenantId BIGINT,
@Type int,
@Code BIGINT
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 3)
Select r.Sname as Text, r.StationId as Value From SystemStations r WHERE r.TenantId=@Code;
If(@Type =11)
Select r.Productvariationname as Text, r.ProductvariationId as Value From SystemProductvariation r INNER JOIN SystemProduct t ON r.ProductId=t.ProductId WHERE t.TenantId=@Code;
If(@Type =14)
Select r.FormulaName as Text, r.FormulaId as Value From LFormulas r WHERE r.TenantId=@Code;
If(@Type = 21)
Select r.Firstname+' '+r.Lastname as Text, r.Userid as Value From SystemStaffs r WHERE r.TenantId=@TenantId;
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
If(@Type = 35)
SELECT A.ShiftId AS Value,A.ShiftCode AS Text FROM StationShifts a INNER JOIN SystemStations B ON A.StationId=B.StationId WHERE B.TenantId=@TenantId AND (A.StationId=@Code OR 0=@Code)

END