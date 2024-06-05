CREATE FUNCTION [dbo].[getlocaldate]()
RETURNS datetime
AS
BEGIN
    RETURN(Select CONVERT(datetime,SWITCHOFFSET(CONVERT(datetimeoffset,GetDate()),(select TimeZoneOffSet from GeneralSettings))));
END