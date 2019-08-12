USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingSummaryOfPaymentsByMedAid`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingSummaryOfPaymentsByMedAid`(in vYear integer,in vPracID bigint)
BEGIN
  
	
SELECT s.ifkPracticeInfoID,ma.sCode,ma.sName,dag.sAgeName,count(dsa.ipkStatementAuditID) as iNumPayments,sum(dsa.fTransactionAmount) as fPaymentTotal
FROM debtor_statement_audit dsa,medical_aid ma,debtor_age_groups dag,accounts a,sites s,debtor_additional da,debtor_transaction_types dtt
where dsa.ifkFeeMedicalAidID = ma.ipkMedicalAidID
and dag.ipkAgeID = dsa.ifkAgeID
and dsa.ifkAccountID = a.ipkAccountID
and s.ipkSiteID = a.ifkSiteID
and da.ifkAccountID = a.ipkAccountID
and da.iEnteredFiscalYear = vYear
and s.ifkPracticeInfoID = vPracID
and dsa.ifkDebtorTransactionType = dtt.ipkDebtorTransactionType
and dtt.bMoneyMovement = 1
group by s.ifkPracticeInfoID,ma.sCode,ma.sName,dag.sAgeName;
  
END$$

DELIMITER ;

