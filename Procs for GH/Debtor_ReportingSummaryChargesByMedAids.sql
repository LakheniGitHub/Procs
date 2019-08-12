USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingSummaryChargesByMedAids`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingSummaryChargesByMedAids`(in vPracID bigint)
BEGIN

  drop TEMPORARY TABLE IF EXISTS tmpCharges; 
  CREATE TEMPORARY TABLE IF NOT EXISTS tmpCharges ENGINE=MEMORY  as  (select s.ifkPracticeInfoID,ma.ipkMedicalAidID,ma.sCode,ma.sName,da.ifkAgeID,sum(dsa.fTransactionAmount) as fCharge,000000000000000000.00 as fTotCredit,000000000000000000.00 as fTotCharge,000000000000000000.00 as fTotal
 
from accounts a, debtor_additional da,medical_aid ma,sites s,debtor_statement_audit dsa,debtor_transaction_types dtt
where a.ipkAccountID = da.ifkAccountID
and a.ifkFeeMedicalAidID = ma.ipkMedicalAidID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vPracID
and dsa.ifkAccountID = a.ipkAccountID
and dtt.ipkDebtorTransactionType = dsa.ifkDebtorTransactionType
and dtt.bMoneyMovement = 0
group by s.ifkPracticeInfoID,ma.ipkMedicalAidID,ma.sCode,ma.sName,da.ifkAgeID)	  ;

drop TEMPORARY TABLE IF EXISTS tmpCredits; 
CREATE TEMPORARY TABLE IF NOT EXISTS tmpCredits ENGINE=MEMORY  as  (select ma.ipkMedicalAidID,sum(dsa.fTransactionAmount) as fCredit
from accounts a, debtor_additional da,medical_aid ma,sites s,debtor_statement_audit dsa,debtor_transaction_types dtt
where a.ipkAccountID = da.ifkAccountID
and a.ifkFeeMedicalAidID = ma.ipkMedicalAidID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vPracID
and dsa.ifkAccountID = a.ipkAccountID
and dtt.ipkDebtorTransactionType = dsa.ifkDebtorTransactionType
and dtt.bMoneyMovement = 1
group by ma.ipkMedicalAidID)	  ;


drop TEMPORARY TABLE IF EXISTS tmpTotCharges; 
CREATE TEMPORARY TABLE IF NOT EXISTS tmpTotCharges ENGINE=MEMORY  as  (select ipkMedicalAidID,sum(fCharge) as vTotCharge
from tmpCharges
group by ipkMedicalAidID)	  ;
  
  update tmpCharges tc,tmpCredits tcrd 
    set tc.fTotCredit = tcrd.fCredit
    where tc.ipkMedicalAidID = tcrd.ipkMedicalAidID;
   
  update tmpCharges tc,tmpTotCharges tcrg
    set tc.fTotCharge = tcrg.vTotCharge
    where tc.ipkMedicalAidID = tcrg.ipkMedicalAidID;
	
  update tmpCharges tc
    set tc.fTotal =  (tc.fTotCharge + tc.fTotCredit);	/*Credits are in negative in DB, thus add so that it does not double - - */
  
     select * from tmpCharges;  
  
END$$

DELIMITER ;

