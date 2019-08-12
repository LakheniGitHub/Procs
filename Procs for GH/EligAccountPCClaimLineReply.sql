USE `promed`;
DROP procedure IF EXISTS `EligAccountPCClaimLineReply`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE `EligAccountPCClaimLineReply` (in vAccID bigint,
												in vTarrifCode varchar(10),
												in vLine integer,
												in vPaidFlag integer,
												in vPayDenyReason varchar(255),
												in vFunderReferenceNumber varchar(255),
												in vPaidAmount decimal(18,2))
BEGIN
 declare vbIsDebtorAcc integer;
 declare v_TransactionType bigint;
 declare msg VARCHAR(128);
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN 
 /*need min mysql 5.6.4 */
	GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
    set msg = substring(concat('[EAPCLR]:',msg),1,128);   	
		ROLLBACK;
    set @G_transaction_started = 0;
    signal sqlstate '45000' SET MESSAGE_TEXT = msg;
 END;
 
  SET autocommit = 0;
   if ((@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
     START TRANSACTION;  
     set @G_transaction_started = 1;
   end; else begin
    set @G_transaction_started = @G_transaction_started + 1;
   end; end if;  
 
 select bDebtorAccount into vbIsDebtorAcc from accounts where ipkAccountID = vAccID;
 
 if ((vbIsDebtorAcc is null) or (vbIsDebtorAcc = 0)) then begin
		update fees set bPaidFlag = vPaidFlag,
						sPayDenyReason = vPayDenyReason,
						sFunderReferenceNumber = vFunderReferenceNumber,
						fPaidAmount = vPaidAmount
			where ifkAccountID = vAccID 
			and sTarrifCode = vTarrifCode
			and iFeeLine  = vLine;
  end; else begin
   INSERT INTO debtor_elig_line_replies (ipkEligLineReplyID,ifkAccountID,iStatementLineNumber,sTarrifCode,bPaidFlag,
										sPayDenyReason,sFunderReferenceNumber,fPaidAmount) VALUES
									(0,vAccID,vLine,vTarrifCode,vPaidFlag,vPayDenyReason,vFunderReferenceNumber,vPaidAmount);
    update debtor_statements set bEligPaidFlag = vPaidFlag where ifkAccountID = vAccID and iLineNumber = vLine;
  end; end if;
  
       if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
END$$

DELIMITER ;

