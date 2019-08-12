use `promed`;
drop procedure if exists `Debtor_ReportingCurrentCreditBalance`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingCurrentCreditBalance`(in vpracid bigint)
begin
/*
 will return all current open credit balance entries on file
*/

	declare vcurrentageid bigint;

	select ipkAgeID into vcurrentageid from debtor_age_groups where sAgeCode = 0; /* only those that are current in age is taken into account here. */

	select s.ifkPracticeInfoID, s.sSiteName,b.sBranchCode,m.ssurname,m.sName,a.sAccountCode,a.fBalance,o.sFirstNames as sassignedto
	from accounts a, members m, sites s,Branches b,
	debtor_additional da left join operators o on o.ipkOperatorID = da.ifkAssignedID
	where a.ipkAccountID = da.ifkAccountID
	and da.bClosed = 0
	and a.fBalance < 0
	and a.ifkMemberID = m.ipkMemberID
	and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and b.ipkBranchID = a.ifkBranchID
	and da.ifkAgeID = vcurrentageid;
end$$

delimiter ;

