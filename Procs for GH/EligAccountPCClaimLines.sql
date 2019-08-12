USE `promed`;
DROP procedure IF EXISTS `EligAccountPCClaimLines`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE `EligAccountPCClaimLines` (in vAccID bigint)
BEGIN
 declare vbIsDebtorAcc integer;
 declare v_TransactionType bigint;
 
 select bDebtorAccount into vbIsDebtorAcc from accounts where ipkAccountID = vAccID;
 
 if ((vbIsDebtorAcc is null) or (vbIsDebtorAcc = 0)) then begin
		Select *
		From fees f 
		where f.ifkAccountID = vAccID
		and f.bFeed = 1
		and sTarrifCode not in ( select distinct(sSMCode) from elig_fee_exclude)
		order by iSequence;
  end; else begin
    select ipkDebtorTransactionType into v_TransactionType from debtor_transaction_types where sTransactionTypeCode = 'FEEADJ'; 
    Select f.*, CASE f.sNappiCode
				WHEN NULL
					THEN '2'
				WHEN ''
					THEN '2'
				ELSE '3'
			   END AS sSMFlag ,sNappiCode as sSMCode,fAmount as fCost,iLineNumber as iFeeLine,iQty as iQuantity
		From debtor_statements f 
		where f.ifkAccountID = vAccID
		and f.ifkDebtorTransactionType = v_TransactionType
		and sTarrifCode not in ( select distinct(sSMCode) from elig_fee_exclude)
		order by iLineNumber;
        
  end; end if;


END$$

DELIMITER ;

