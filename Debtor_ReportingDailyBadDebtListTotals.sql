use `promed`;
drop procedure if exists `Debtor_ReportingDailyBadDebtListTotals`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyBadDebtListTotals`(in vday date, in vpracid bigint)
begin

  /* 
    get fee list totals and fees for day given for practice
  */
  declare vendDate timestamp;
  
  set vendDate = concat(vday,' 23:59:59');
  
  select  s.ifkPracticeInfoID,s.sSiteName,b.sBranchCode,sum(ds.fTransActionAmount) as ftotval,count(distinct(a.ipkAccountID)) as itotacc                                     
from debtor_statement_audit ds,accounts a,patients p,sites s,members m,medical_aid ma,debtor_transAction_types dtt,Branches b
 where ds.dDateEntered >= vday and ds.dDateEntered <= vendDate               
 and a.ipkAccountID = ds.ifkAccountID
 and p.ipkPatientID = a.ifkPatientID
 and a.ifkSiteID = s.ipkSiteID
 and a.ifkMemberID = m.ipkMemberID
 and m.ifkMedicalAidID = ma.ipkMedicalAidID
 and dtt.ipkDebtorTransActionType = ds.ifkDebtorTransActionType
  and dtt.sTransactionTypeCode in ('badwoff','handover','blacklst')
  and s.ifkPracticeInfoID = vpracid               
  and a.ifkBranchID = b.ipkBranchID
  group by s.ifkPracticeInfoID,s.sSiteName,b.sBranchCode;
end$$

delimiter ;

