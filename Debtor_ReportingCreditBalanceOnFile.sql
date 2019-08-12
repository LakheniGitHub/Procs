use `promed`;
drop procedure if exists `Debtor_ReportingCreditBalanceOnFile`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingCreditBalanceOnFile`(in vpracid bigint)
begin
/*
 will return all current open credit balance entries on file
*/
select s.ifkPracticeInfoID, s.sSiteName,b.sBranchCode,m.ssurname,m.sName,a.sAccountCode,a.fBalance,o.sFirstNames as sassignedto
from accounts a, members m, sites s,Branches b,
debtor_additional da left join operators o on o.ipkOperatorID = da.ifkAssignedID
where a.ipkAccountID = da.ifkAccountID
and da.bClosed = 0
and a.fBalance < 0
and a.ifkMemberID = m.ipkMemberID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vpracid
and b.ipkBranchID = a.ifkBranchID;
end$$

delimiter ;

