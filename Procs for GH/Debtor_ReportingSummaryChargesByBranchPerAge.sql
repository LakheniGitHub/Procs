USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingSumbaryChargesByBranchPerAge`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Debtor_ReportingSumbaryChargesByBranchPerAge`(in vPracID bigint)
BEGIN

  drop TEMPORARY TABLE IF EXISTS tmpCharges; 
  CREATE TEMPORARY TABLE IF NOT EXISTS tmpCharges ENGINE=MEMORY  as  (select s.ifkPracticeInfoID,ba.ipkBranchID,ba.sBranchCode,ba.sDescription,da.ifkAgeID,sum(dsa.fTransactionAmount) as fCharge,000000000000000000.00 as fTotCredit
 
from accounts a, debtor_additional da,branches ba,sites s,debtor_statement_audit dsa,debtor_transaction_types dtt,debtor_age_groups dag
where a.ipkAccountID = da.ifkAccountID
and a.ifkBranchID = ba.ipkBranchID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vPracID
and dsa.ifkAccountID = a.ipkAccountID
and dtt.ipkDebtorTransactionType = dsa.ifkDebtorTransactionType
and dtt.bMoneyMovement = 0
and dag.ipkAgeID = da.ifkAgeID
group by s.ifkPracticeInfoID,ba.ipkBranchID,ba.sBranchCode,ba.sDescription,da.ifkAgeID)	  ;

drop TEMPORARY TABLE IF EXISTS tmpCredits; 
CREATE TEMPORARY TABLE IF NOT EXISTS tmpCredits ENGINE=MEMORY  as  (select s.ifkPracticeInfoID,ba.ipkBranchID,ba.sBranchCode,ba.sDescription,da.ifkAgeID,sum(dsa.fTransactionAmount) as fCredit,0 as bToInsert
from accounts a, debtor_additional da,branches ba,sites s,debtor_statement_audit dsa,debtor_transaction_types dtt
where a.ipkAccountID = da.ifkAccountID
and a.ifkBranchID = ba.ipkBranchID
and a.ifkSiteID = s.ipkSiteID
and s.ifkPracticeInfoID = vPracID
and dsa.ifkAccountID = a.ipkAccountID
and dtt.ipkDebtorTransactionType = dsa.ifkDebtorTransactionType
and dtt.bMoneyMovement = 1
group by s.ifkPracticeInfoID,ba.ipkBranchID,ba.sBranchCode,ba.sDescription,da.ifkAgeID)	  ;

  update tmpCharges tc,tmpCredits tcrd 
    set tc.fTotCredit = tcrd.fCredit
    where tc.ipkBranchID = tcrd.ipkBranchID
	and tc.ifkAgeID = tcrd.ifkAgeID;
	
	update tmpCredits tcrd set tcrd.bToInsert = 1 where tcrd.ipkBranchID not in (select distinct tc.ipkBranchID from tmpCharges tc);
    
	insert into tmpCharges (select ifkPracticeInfoID,ipkBranchID,sBranchCode,sDescription,ifkAgeID,0.0,fCredit from tmpCredits where bToInsert = 1) ;
	
	select * from tmpCharges;  
  
END$$

DELIMITER ;

