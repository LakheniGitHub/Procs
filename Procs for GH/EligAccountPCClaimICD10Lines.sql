USE `promed`;
DROP procedure IF EXISTS `EligAccountPCClaimICD10Lines`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE `EligAccountPCClaimICD10Lines` (in vAccID bigint,
												in vTarrifCode varchar(10),
												in vLine integer)
BEGIN
 declare vbIsDebtorAcc integer;
 declare v_TransactionType bigint;
 
 select bDebtorAccount into vbIsDebtorAcc from accounts where ipkAccountID = vAccID;
 
 if ((vbIsDebtorAcc is null) or (vbIsDebtorAcc = 0)) then begin
		select * 
			from account_fee_icd10 af,icd_10 ic
			where af.ifkICD10ID = ic.ipkICD10ID
			and af.ifkAccountID = vAccID
			and af.sTarrifCode = vTarrifCode
			and af.iFeeLineNumber = vLine
			order by af.iLineNumber;
  end; else begin
    select * 
			from debtor_statement_icd10 af,icd_10 ic
			where af.ifkICD10ID = ic.ipkICD10ID
			and af.ifkAccountID = vAccID
			and af.sTarrifCode = vTarrifCode
			and af.iStatementLineNumber = vLine
			order by af.iLineNumber;
  end; end if;
END$$

DELIMITER ;

