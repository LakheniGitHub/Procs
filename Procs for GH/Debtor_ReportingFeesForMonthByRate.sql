USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingFeesForMonthByRate`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingFeesForMonthByRate`(in vDate date)
BEGIN
  declare vStartDate timestamp;
  declare vEndDate timestamp;
  declare iYear integer;
  declare iMonth integer;
  declare v_FeetransTypeID bigint;
  
  set iYear  = year(vDate);
  set iMonth = month(vDate);
  set vStartDate = concat(iYear,'-',iMonth,'-01');
  
  set vEndDate = last_day(vDate);
  set vEndDate = TIMESTAMPADD(HOUR,23,vEndDate);
  set vEndDate = TIMESTAMPADD(MINUTE,59,vEndDate);
  set vEndDate = TIMESTAMPADD(SECOND,59,vEndDate);
  
    select ipkDebtorTransactionType into v_FeetransTypeID from debtor_transaction_types where sTransactionTypeCode = 'FEEADJ';
	
  
	SELECT  s.ifkPracticeInfoID, m.iRateCode,count(dsa.ifkAccountID) as iAccountCount,sum(dsa.fTransactionAmount) as fTransactionTotal
	FROM debtor_statement_audit dsa,medical_aid m,accounts a,sites s
	where m.ipkMedicalAidID = dsa.ifkFeeMedicalAidID
	and dsa.dDateEntered >= vStartDate
	and dsa.dDateEntered <= vEndDate
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and dsa.ifkDebtorTransactionType = v_FeetransTypeID
	group by  s.ifkPracticeInfoID,m.iRateCode;
  
  
END$$

DELIMITER ;

