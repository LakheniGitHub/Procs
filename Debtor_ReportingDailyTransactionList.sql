use `promed`;
drop procedure if exists `Debtor_ReportingDailyTransactionList`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyTransactionList`(in vday date, in vsiteid bigint)
begin

  declare vendDate timestamp;
  
  set vendDate = concat(vday,' 23:59:59');
  
  select  a.ifkSiteID,b.sBranchCode,b.sDescription,dtt.sTransactionTypeCode,dtt.sTransactionDescription,sum(ds.fTransActionAmount) as ftotamount,sum(ds.fAmountExclVat) as ftotamountexclvat,sum(ds.fVatAmount) as ftotvatamount
from debtor_statement_audit ds,accounts a,debtor_transAction_types dtt,Branches b
 where ds.dDateEntered >= vday and ds.dDateEntered <= vendDate
 and a.ipkAccountID = ds.ifkAccountID
 and a.ifkSiteID = vsiteid
 and a.ifkBranchID = b.ipkBranchID
 and dtt.ipkDebtorTransActionType = ds.ifkDebtorTransActionType
 and  dtt.sTransactionTypeCode not in ('fee','receipt')
 group by a.ifkSiteID,b.sBranchCode,b.sDescription,dtt.sTransactionTypeCode,dtt.sTransactionDescription;
 
end$$

delimiter ;

