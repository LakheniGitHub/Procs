USE `promed`;
DROP procedure IF EXISTS `DebtorSaveRunningTotals`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DebtorSaveRunningTotals`(in vDebtorType bigint,
											in vPracID bigint,
											in vSiteID bigint,
											in vBranchID bigint,
											in vLineDate date,
											in vDateAdded date,
										    in vMOP bigint,
                                            in vAmount decimal(18,2),
                                            in vVatAmount decimal(18,2),
                                            in vAmountExclVat decimal(18,2)
                                            )
BEGIN
  /* 
  Save does check if line exist for mop and date ,practice and site and debttype
   if exist, update else insert
   
   Note this stores in
   debtor_running_totals -> Based on Line date (can be changed, backdated)
   debtor_dayend_totals -> Based on Date entered (line created - fixed)
  */
  declare vExist integer;
  declare vFiscalYear integer;
  declare vFiscalMonth  integer;
  declare vFiscalQuarter  integer;
	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[DSRT]:',msg),1,128);   	
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
  
/*Store totals based on Line date */  
  if (vMOP is not null) then begin
	  select ipkDebtorRunningTotalID into vExist
			from debtor_running_totals 
				where ifkPracticeInfoID = vPracID 
				and ifkSiteID = vSiteID 
				and ifkBranchID = vBranchID
				and ifkDebtorTransactionType = vDebtorType 
				and dLineDate = vLineDate 
				and ifkMethodOfPaymentID = vMOP;
  end; else begin
	  select ipkDebtorRunningTotalID into vExist
			from debtor_running_totals 
				where ifkPracticeInfoID = vPracID 
				and ifkSiteID = vSiteID 
				and ifkBranchID = vBranchID
				and ifkDebtorTransactionType = vDebtorType 
				and dLineDate = vLineDate;  
  end; end if; 
            
  if ((vExist <= 0) or (vExist is null)) then begin
        call DebtorPracticeFiscalInfoForDate(vPracID,vLineDate,vFiscalYear,vFiscalQuarter,vFiscalMonth);  
		INSERT INTO debtor_running_totals (ipkDebtorRunningTotalID,ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,dLineDate,fAmount,fVatAmount,ifkMethodOfPaymentID,fAmountExclVat,
								dLastUpdated,iFiscalYear,iFiscalMonth,iFiscalQuarter)
								VALUES
					(0,vPracID,vSiteID,vBranchID,vDebtorType,vLineDate,vAmount,vVatAmount,vMOP,vAmountExclVat,
                      CURRENT_TIMESTAMP,vFiscalYear,vFiscalMonth,vFiscalQuarter,vMedAidID,vRefDocID);
    
  end; else begin
		UPDATE debtor_running_totals	
				SET fAmount = fAmount + vAmount, 
				fVatAmount = fVatAmount + vVatAmount, 
				fAmountExclVat = fAmountExclVat + vAmountExclVat, 
				dLastUpdated = CURRENT_TIMESTAMP
		WHERE ipkDebtorRunningTotalID = vExist;
  
  end; end if;
  
  /*Store totals based on date entered*/
    if (vMOP is not null) then begin
      select ipkDayEndTotalID into vExist
		from debtor_dayend_totals 
			where ifkPracticeInfoID = vPracID 
            and ifkSiteID = vSiteID 
			and ifkBranchID = vBranchID
            and ifkDebtorTransactionType = vDebtorType 
            and dDate = vDateAdded 
            and ifkMethodOfPaymentID = vMOP;
	end; else begin
      select ipkDayEndTotalID into vExist
		from debtor_dayend_totals 
			where ifkPracticeInfoID = vPracID 
            and ifkSiteID = vSiteID 
			and ifkBranchID = vBranchID
            and ifkDebtorTransactionType = vDebtorType 
            and dDate = vDateAdded ;
    end; end if;	
            
  if ((vExist <= 0) or (vExist is null)) then begin
        call DebtorPracticeFiscalInfoForDate(vPracID,vDateAdded,vFiscalYear,vFiscalQuarter,vFiscalMonth);  
		INSERT INTO debtor_dayend_totals (ipkDayEndTotalID,ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,dDate,fAmount,fVatAmount,ifkMethodOfPaymentID,fAmountExclVat,
								iFiscalYear,iFiscalMonth,iFiscalQuarter)
								VALUES
					(0,vPracID,vSiteID,vBranchID,vDebtorType,vDateAdded,vAmount,vVatAmount,vMOP,vAmountExclVat,
                      vFiscalYear,vFiscalMonth,vFiscalQuarter,vMedAidID,vRefDocID);
    
  end; else begin
		UPDATE debtor_dayend_totals	
				SET fAmount = fAmount + vAmount, 
				fVatAmount = fVatAmount + vVatAmount, 
				fAmountExclVat = fAmountExclVat + vAmountExclVat
		WHERE ipkDayEndTotalID = vExist;
  
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

