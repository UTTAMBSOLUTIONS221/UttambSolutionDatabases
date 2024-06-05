CREATE PROCEDURE [dbo].[Usp_Getlistmodel]
@Type int
AS
BEGIN
SET NOCOUNT ON;
If(@Type = 0)
Select r.Rolename as Text, r.RoleId as Value From SystemRoles r WHERE r.Isdefault=0;
If(@Type = 1)
Select r.Permissionname as Text, r.permissionId as Value From Systempermissions r WHERE r.Isadmin=0;
If(@Type = 2)
Select r.Assetname as Text, r.Assetid as Value From Systemassets r;
If(@Type = 3)
Select r.codename as Text, r.Phoneid as Value From Systemphonecodes r;
If(@Type = 4)
Select r.Vehiclemakename as Text, r.Vehiclemakeid as Value From Systemvehiclemakes r;
If(@Type = 6)
Select r.Firstname+' '+ r.Lastname as Text, r.Customerid as Value From Systemcustomers r;
If(@Type = 7)
Select r.Assetnumber as Text, r.Assetdetailid as Value From Systemassetdetail r;
END
