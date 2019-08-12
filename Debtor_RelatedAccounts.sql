use `promed`;
drop procedure if exists `Debtor_RelatedAccounts`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_RelatedAccounts`(in vAccID bigint, in bCheckOnPatient integer)
begin

   /*
     resturn result based on accounts linked to member with same ID number, can select to rather return all accounts linked to patient
   */
   declare vIDNumber varchar(20);
    select m.sIDNumber into vIDNumber from accounts a, members m where m.ipkMemberID = a.ifkMemberID and a.ipkAccountID = vAccID;
    
	if (bCheckOnPatient = 0) then begin
			select a.fBalance,a.fReceiptTotal,a.fVatTotal,a.fFeedTotal,
		p.sTitle as p_sTitle,p.sInitials as p_sInitials,p.sSurname as p_sSurname,p.sName as p_sName,p.sIDNumber as p_sIDNumber,
		m.sTitle as m_sTitle,m.sInitials as m_sInitials,m.sSurname as m_sSurname,m.sName as m_sName,m.sIDNumber as m_sIDNumber,
		a.dExamDate,a.ipkAccountID,a.sAccountCode
		  from accounts a,patients p, members m
		  where a.ifkPatientID = p.ipkPatientID
		  and a.ifkMemberID = m.ipkMemberID
		  and m.sIDNumber = vIDNumber;
		  
	end; else begin
	select m.sIDNumber into vIDNumber from accounts a, patients m where m.ipkPatientID = a.ifkPatientID and a.ipkAccountID = vAccID;
	
			select a.fBalance,a.fReceiptTotal,a.fVatTotal,a.fFeedTotal,
		p.sTitle as p_sTitle,p.sInitials as p_sInitials,p.sSurname as p_sSurname,p.sName as p_sName,p.sIDNumber as p_sIDNumber,
		m.sTitle as m_sTitle,m.sInitials as m_sInitials,m.sSurname as m_sSurname,m.sName as m_sName,m.sIDNumber as m_sIDNumber,
		a.dExamDate,a.ipkAccountID,a.sAccountCode
		  from accounts a,patients p, members m
		  where a.ifkPatientID = p.ipkPatientID
		  and a.ifkMemberID = m.ipkMemberID
		  and p.sIDNumber = vIDNumber;	
   end; end if;	
  
end$$

delimiter ;

