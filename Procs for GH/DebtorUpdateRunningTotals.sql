USE `promed`;
DROP procedure IF EXISTS `DebtorUpdateRunningTotals`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DebtorUpdateRunningTotals`( in vStatementID bigint,
												in vAmount decimal(18,2),
                                                in vVatAmount decimal(18,2),
                                                in vAmountExclVat decimal(18,2),
                                                in vMethodOfPaymentID bigint,
                                                in vLineDate timestamp                                               
                                                )
BEGIN
  declare vRunID integer;
  declare vAccID bigint;
  declare vPracID bigint;
  declare vSiteID bigint;
  declare vBranchID bigint;
  declare vDebTypeID bigint;
  declare vOld_MOPID bigint;
  declare vOld_LDate date;
  declare vOld_DateAdded date;
  declare vorig_fAmount decimal(18,2) ;
  declare vorig_fVatAmount decimal(18,2) ;  
  declare vorig_fAmountExclVat decimal(18,2) ;  
  declare vVatExclWaarde decimal(18,2) ;
  declare vaudit_fAmount decimal(18,2) ;
  declare vaudit_fVatAmount decimal(18,2) ;  
  declare bKeychange smallint;
	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[DURT]:',msg),1,128);   	
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
	 
  set bKeychange = 0;
  
  select ifkAccountID,ifkDebtorTransactionType,cast(dLineDate as date),cast(dDateEntered as date),ifkMethodOfPaymentID ,fAmount,fVatAmount ,fAmountExclVat
          into vAccID,vDebTypeID,vOld_LDate,vOld_DateAdded,vOld_MOPID,vorig_fAmount,vorig_fVatAmount,vorig_fAmountExclVat
         from debtor_statements where ipkStatementEntryID = vStatementID;
  

  select a.ifkSiteID,s.ifkPracticeInfoID,a.ifkBranchID into vSiteID,vPracID ,vBranchID
     from accounts a,sites s where a.ipkAccountID = vAccID and a.ifkSiteID  = s.ipkSiteID;
  if ((vStatementID > 0) and (vStatementID is not null)) then begin  
	  if (  vLineDate <> vOld_LDate) then begin
		 /*
		 Line date not the same, thus reverse the entry against old line date and old method of payment type
		 before writing new entry
		 */
         call DebtorSaveRunningTotals(vDebTypeID,vPracID,vSiteID,vBranchID,vOld_LDate,vOld_DateAdded,vOld_MOPID,(-1 * vorig_fAmount),(-1 * vorig_fVatAmount),(-1 * vorig_fAmountExclVat));
		 set bKeychange = 1;
		 
	  end; else begin
		 if (  vOld_MOPID <> vMethodOfPaymentID) then begin
			/*
			Line date still the same BUT the method of payment has changed. Thus reverse entry for old method of
			payment before writing new entry
			*/
            call DebtorSaveRunningTotals(vDebTypeID,vPracID,vSiteID,vBranchID,vOld_LDate,vOld_DateAdded,vOld_MOPID,(-1 * vorig_fAmount),(-1 * vorig_fVatAmount),(-1 * vorig_fAmountExclVat));
			set bKeychange = 1;
			
		 end; end if;
	  end; end if;
  end; else begin
     /*
     Need statement to get account to get practice and site, thus not allowed.
     */
    set bKeychange = 1;
	signal sqlstate '45000'
	SET MESSAGE_TEXT = "Running total error - Statement must exist first";    
  end; end if;
  /*select * from debtor_running_totals where */
  
  if (bKeychange = 0) then begin
		set vaudit_fAmount = vorig_fAmount - vAmount;
		set vaudit_fVatAmount = vorig_fVatAmount - vVatAmount;
		set vaudit_fAmount = -1 *  vaudit_fAmount;
		set vaudit_fVatAmount = -1 * vaudit_fVatAmount;
		set vVatExclWaarde = (vaudit_fAmount -  vaudit_fVatAmount);  
        call DebtorSaveRunningTotals(vDebTypeID,vPracID,vSiteID,vBranchID,vLineDate,vOld_DateAdded,vMethodOfPaymentID,vaudit_fAmount,vaudit_fVatAmount,vVatExclWaarde);
  end; else begin
    /**/
    call DebtorSaveRunningTotals(vDebTypeID,vPracID,vSiteID,vBranchID,vLineDate,vOld_DateAdded,vMethodOfPaymentID,vAmount,vVatAmount,vAmountExclVat);
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

