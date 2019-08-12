use `promed`;
drop procedure if exists `Debtor_ReportingDailyControlTotalsDetail`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyControlTotalsDetail`(in vday date, in vpracid bigint)
begin

     declare vendDate timestamp;
  
  set vendDate = concat(vday,' 23:59:59');
  
  select  a.sAccountCode,m.ssurname as M_surname,m.sName as M_NAME, m.sTITLE as M_TITLE,m.sInitials as M_INITIALS,m.sIDNumber as M_IDNUMBER,ma.sCode as m_MEDAIDCODE,
        ds.dDateEntered,ds.fTransActionAmount,ds.fAmountExclVat,ds.fVatAmount,ds.iTransActionLINENUMBER,
		ds.sTransactionDescription,ds.sNappiCode,ds.sTarrifCode,ds.sStructureCode,ds.iQTY,b.sBranchCode,s.sSiteName,s.ifkPracticeInfoID,dtt.sTransactionTypeCode,dtt.sTransactionDescription as stransDescription
from debtor_statement_audit ds,accounts a,patients p,sites s,members m,medical_aid ma,debtor_transAction_types dtt,Branches b
 where ds.dDateEntered >= vday and ds.dDateEntered <= vendDate
 and a.ipkAccountID = ds.ifkAccountID
 and p.ipkPatientID = a.ifkPatientID
 and a.ifkSiteID = s.ipkSiteID
 and a.ifkMemberID = m.ipkMemberID
 and m.ifkMedicalAidID = ma.ipkMedicalAidID
 and dtt.ipkDebtorTransActionType = ds.ifkDebtorTransActionType
 /*and dtt.bMoneyMovement = 0 and dtt.sTransactionTypeCode not in ('fee') /*,'smallwoff','badwoff','handover','blacklst'*/
 and ds.sTarrifCode not in ('00092','00091')
  and s.ifkPracticeInfoID = vpracid
  and a.ifkBranchID = b.ipkBranchID
 order by a.sAccountCode,ds.iTransActionLINENUMBER;
   
end$$

delimiter ;

