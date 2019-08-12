USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingAccountsNotFeedYet`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingAccountsNotFeedYet`(in vNumberDays integer,in vPracID bigint)
BEGIN
  select b.sBranchCode,a.sAccountCode,a.dExamDate,
 (select e.sExamCode from exams e, account_exams ae where ae.ifkAccountID = a.ipkAccountID and ae.ifkExamID = e.ipkExamID limit 1) as vExam,
 p.sInitials as vP_Intials,p.sSurname as vP_Surname,ma.sCode as vMedCode,rd.sInitials as vR_Initials, rd.sSurname as vR_Surname,s.ifkPracticeInfoID,
 m.sAddressLine1,m.sAddressLine2
from accounts a, debtor_additional da,branches b,patients p,medical_aid ma,referring_doctors rd,sites s,member_addresses m,member_address_type mt
where a.ipkAccountID = da.ifkAccountID
and a.iLineCount = 0
and a.dDateEntered < date_sub(current_date,interval vNumberDays day)
and b.ipkBranchID = a.ifkBranchID
and p.ipkPatientID = a.ifkPatientID
and a.ifkFeeMedicalAidID = ma.ipkMedicalAidID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vPracID
and a.ifkMemberID = m.ifkMemberID
and mt.ipkMemberAddressTypeID = m.ifkMemberAddressTypeID
and mt.sCode = 'P'
and rd.ipkReferringDoctorID = a.ifkPrimaryReferringDoctorID;

END$$

DELIMITER ;

