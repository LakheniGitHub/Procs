USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingMonthlyRefundList`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingMonthlyRefundList`(in vDate date,in vPracID bigint)
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
  
SELECT s.ifkPracticeInfoID,a.sAccountCode,p.sInitials,p.sSurname,dsa.fTransactionAmount,dsa.sTransactionDescription,dsa.dLineUpdateDate,a.dExamDate,o.sUserName as sCapturedBy
FROM debtor_statement_audit dsa ,accounts a,sites s,debtor_transaction_types dtt,patients p,operators o
where dsa.ifkAccountID = a.ipkAccountID
and s.ipkSiteID = a.ifkSiteID
and a.dDateEntered >= vStartDate
and a.dDateEntered <= vEndDate
and s.ifkPracticeInfoID = vPracID
and dsa.ifkDebtorTransactionType = dtt.ipkDebtorTransactionType
and dtt.sTransactionTypeCode = 'REFUND' 
and p.ipkPatientID = a.ifkPatientID
and dsa.ifkCapturedBy = o.ipkOperatorID;
  
  
END$$

DELIMITER ;

