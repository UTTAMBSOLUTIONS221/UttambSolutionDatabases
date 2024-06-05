CREATE PROCEDURE [dbo].[Usp_GetListModelbycode]
@Type int,
@Code BIGINT
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 21)
Select r.Fullname as Text, r.StaffId as Value From SystemStaffs r;
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

END