﻿
CREATE VIEW  [dbo].[VWFinanceTransactions] AS SELECT FinancetransactionId,TenantId,transactioncode,Saledescription,ActualDate,DateCreated,SaleRefence,'' AS Saletransactiontype,COALESCE(ParentId,0) AS ParentId,AutomationRefence FROM FinanceTransactions
