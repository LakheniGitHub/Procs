USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingListOfRefDocTotals`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingListOfRefDocTotals`(in vDate date,in vPracID bigint)
BEGIN
  declare vStartDate timestamp;
  declare vEndDate timestamp;
  declare iYear integer;
  declare iMonth integer;
  
  set iYear  = year(vDate);
  set iMonth = month(vDate);
  set vStartDate = concat(iYear,'-',iMonth,'-01');
  
  set vEndDate = last_day(vStartDate);
  set vEndDate = TIMESTAMPADD(HOUR,23,vEndDate);
  set vEndDate = TIMESTAMPADD(MINUTE,59,vEndDate);
  set vEndDate = TIMESTAMPADD(SECOND,59,vEndDate);
  
	
select s.ifkPracticeInfoID,r.sCode,r.sSurname,r.sInitials,sum(a.fFeedTotal) as fTotal,count(a.ipkAccountID) as iCount,cast(sum(a.fFeedTotal) / count(a.ipkAccountID) as decimal(18,2)) as fAverage
from referring_doctors r,accounts a,debtor_additional da,sites s                 
where a.ifkPrimaryReferringDoctorID = r.ipkReferringDoctorID
and da.ifkAccountID = a.ipkAccountID
and a.dDateEntered >= vStartDate
and a.dDateEntered <= vEndDate
and s.ipkSiteID = a.ifkSiteID
and s.ifkPracticeInfoID = vPracID
group by r.sCode,r.sSurname,r.sInitials;
  
END$$

DELIMITER ;

