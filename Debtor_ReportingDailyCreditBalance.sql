use `promed`;
drop procedure if exists `Debtor_ReportingDailyCreditBalance`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyCreditBalance`(in vpracid bigint)
begin

  /* 
    get list of accounts in credit
  */
  declare vactiveyear integer;
  declare vactivemonth integer;
  declare vactivequarter integer;  
  
  select iActiveFiscalMonth,iActiveFiscalYear,iActiveFiscalQuarter into vactivemonth,vactiveyear,vactivequarter  from debtor_practice_info where ifkPracticeInfoID = vpracid;
  
select a.sAccountCode,
        m.ssurname as M_surname,m.sName as M_NAME, m.sTITLE as M_TITLE,m.sInitials as M_INITIALS,m.sIDNumber as M_IDNUMBER,ma.sCode as m_MEDAIDCODE,m.sMedicalAidReference as m_medaidref,ma.sName as ma_medaidNAME,
        a.dDateEntered,a.fBalance,b.sBranchCode,s.sSiteName,s.ifkPracticeInfoID
from accounts a,sites s,members m,medical_aid ma,Branches b , debtor_additional da,debtor_statement_audit t1
  join (select da2.ifkAccountID, MAX(da2.ipkStatementAuditID) ipkStatementAuditID 
       from debtor_statement_audit da2,accounts a2,sites s2
	     where da2.iRunFiscalYear = vactiveyear and da2.iRunFiscalMonth = vactivemonth 
		 and da2.ifkAccountID = a2.ipkAccountID
		 and a2.ifkSiteID = s2.ipkSiteID
		 and s2.ifkPracticeInfoID = vpracid
		 group by ifkAccountID) t2
    on t1.ipkStatementAuditID = t2.ipkStatementAuditID and t1.ifkAccountID = t2.ifkAccountID
    where t1.fBalance < 0
    and da.bClosed = 0
	and t1.iRunFiscalYear = vactiveyear 
	and t1.iRunFiscalMonth = vactivemonth 
    and a.ipkAccountID = t1.ifkAccountID
    and a.ipkAccountID = da.ifkAccountID
     and a.ifkSiteID = s.ipkSiteID
 and a.ifkMemberID = m.ipkMemberID
 and m.ifkMedicalAidID = ma.ipkMedicalAidID
  and s.ifkPracticeInfoID = vpracid
  and a.ifkBranchID = b.ipkBranchID
 order by a.ifkSiteID,a.ifkBranchID,m.ssurname,m.sInitials,a.sAccountCode;
 /*
 patients p,
 and p.ipkPatientID = a.ifkPatientID
 
 p.ssurname as P_surname,p.sName as P_NAME,p.sInitials as P_INITIALS,p.sTITLE as P_TITLE,p.sIDNumber as P_IDNUMBER,
 */
 
end$$

delimiter ;

