use `promed`;
drop procedure if exists `Debtor_ReportingConsolidatedInfo`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingConsolidatedInfo`(in vAccID bigint)
begin

  /* 
    get Consolidate info per account for account id
  */
  select a.fBalance,a.fReceiptTotal,a.fVatTotal,a.fFeedTotal,
p.sTitle as p_sTitle,p.sInitials as p_sInitials,p.sSurname as p_sSurname,p.sName as p_sName,p.sIDNumber as p_sIDNumber,
		m.sTitle as m_sTitle,m.sInitials as m_sInitials,m.sSurname as m_sSurname,m.sName as m_sName,m.sIDNumber as m_sIDNumber,
		a.dExamDate,a.ipkAccountID,a.sAccountCode
  from accounts a,patients p, members m
  where a.ifkPatientID = p.ipkPatientID
  and a.ifkMemberID = m.ipkMemberID
  and a.ipkAccountID = vAccID;
 
end$$

delimiter ;

