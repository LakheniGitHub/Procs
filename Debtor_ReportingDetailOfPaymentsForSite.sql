USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingDetailOfPaymentsForSite`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingDetailOfPaymentsForSite`(in vDate date,in vSite bigint)
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
  
	
SELECT s.ifkPracticeInfoID,dsa.ipkStatementAuditID,a.sAccountCode,p.sInitials,p.sSurname,dsa.fTransactionAmount,dsa.sTransactionDescription,dsa.dLineUpdateDate,a.dExamDate,o.sUserName as sCapturedBy,s.sSiteName
FROM debtor_statement_audit dsa ,accounts a,sites s,debtor_transaction_types dtt,patients p,operators o
where dsa.ifkAccountID = a.ipkAccountID
and s.ipkSiteID = a.ifkSiteID
and dsa.dDateEntered >= vStartDate
and dsa.dDateEntered <= vEndDate
and s.ipkSiteID = vSite
and dsa.ifkDebtorTransactionType = dtt.ipkDebtorTransactionType
and dtt.sTransactionTypeCode = 'RECEIPT' 
and p.ipkPatientID = a.ifkPatientID
and dsa.ifkCapturedBy = o.ipkOperatorID;
  

  
END$$

DELIMITER ;

