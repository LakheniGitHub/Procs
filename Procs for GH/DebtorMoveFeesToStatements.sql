USE promed;
DROP procedure IF EXISTS DebtorMoveFeesToStatements;

DELIMITER $$
USE promed$$
CREATE DEFINER=root@localhost PROCEDURE DebtorMoveFeesToStatements(in viAccID bigint)
BEGIN
 /*
   Developer : Johannes Pretorius
   DAte : 2 Maart 2018
   Purpose : To Move the fee lines to statements and update accounts as a debtor account, thus future feeing is not allowed, must be done via debtor interface
   If account is already a debtor account , dont redo it, ignore whole move as it was already done then
   
   NOTE : We need to link operator ID to fee lines as it gets set in future, for now will try and lookup it via fees spromedloginname but will have to later have id
   if not found will use gloval user
      
 */
 
   declare vIDebtorAcc smallint;
   declare v_operatorid smallint;
    declare  v_debtortype bigint;
    declare v_StmtID bigint;
    declare v_TaxType integer;
    declare  v_fTaxPercentage decimal(18,2);
    declare  v_fVatPercentage decimal(18,2);
    
    declare vicd10bestaan integer;
    declare vicdlinenum integer;
    
    declare  v_dLineDate timestamp;
      declare  v_sDescription varchar(100);
      declare  v_sTarrifCode varchar(10);
      declare  v_sSMCode  varchar(10);
      declare  v_fUnitPrice decimal(18,2);
      declare  v_fVATAmount  decimal(18,2);
      declare  v_sStrucCode  varchar(10);
      declare  v_sPromedLoginName varchar(50);
      declare v_sDiagnosesCodes varchar(80);
      declare v_iFeeLine integer;
	  declare v_iQuantity integer;
	  declare vAccDateEntered timestamp;
	  declare vDateDiffDays integer;
	  declare vAgeID bigint;

   declare msg VARCHAR(128);
   

      DECLARE done INT DEFAULT FALSE;
   
   DECLARE fees CURSOR FOR SELECT dLineDate,      sDescription,      sTarrifCode,      sSMCode,      ifnull(fUnitPrice,0),      ifnull(fVATAmount,0),      sStrucCode,      sPromedLoginName,iFeeLine,iQuantity
									FROM fees where bFeed = 1 and ifkAccountID = viAccID;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;  


 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN 
 /*need min mysql 5.6.4 */
	GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
    set msg = substring(concat('[DMFTS]:',msg),1,128);   	
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

   select bDebtorAccount,dDateEntered into vIDebtorAcc,vAccDateEntered from accounts where ipkaccountid = viAccID;
   select fvat into v_fVatPercentage from vat_factor;
   

   if ((vIDebtorAcc is null) or (vIDebtorAcc = 0)) then begin
	   select ipkDebtorTransactionType into v_debtortype from debtor_transaction_types where sTransactionTypeCode = 'FEEADJ';
	   select ipkTaxType,fTaxPercentage into v_TaxType,v_fTaxPercentage from debtor_taxes where sTaxCode = 'VAT';
      
      
       
        OPEN fees;
    SET done = FALSE ;
        read_loop_fees: LOOP

		FETCH fees INTO v_dLineDate,      v_sDescription,      v_sTarrifCode,      v_sSMCode,      v_fUnitPrice,      v_fVATAmount,      v_sStrucCode,      v_sPromedLoginName ,v_iFeeLine,v_iQuantity;
        IF done THEN
		  LEAVE read_loop_fees;
		END IF;

      select ipkOperatorID into v_operatorid from  operators  where  sUserName = v_sPromedLoginName;
      if (v_operatorid is null) then begin
        select ipkOperatorID into v_operatorid from  operators  where  sUserName = 'GlobalPatMan';  
      end; end if;
      if (CHAR_LENGTH(v_sSMCode) < 9) then begin
        set v_sSMCode = '';
      end; end if;
      if (v_sSMCode * 1 <> v_sSMCode) then begin
        set v_sSMCode = '';
      end; end if;
      CALL DebtorStatementLineAdd(v_debtortype,v_TaxType, viAccID, v_dLineDate,v_iQuantity, v_sDescription,v_sTarrifCode, v_sSMCode, v_fUnitPrice, v_fVATAmount, v_fVatPercentage, v_sStrucCode, v_operatorid, null,null,'','',null,null,v_StmtID);
           select iLineNumber into vicdlinenum  from debtor_statements where ipkStatementEntryID = v_StmtID;

           select count(ipkAccountStatementICD10ID) into vicd10bestaan from  debtor_statement_icd10 where ifkAccountID = viAccID and  iStatementLineNumber = vicdlinenum;
           if ((vicd10bestaan is null) or (vicd10bestaan = 0)) then begin

              insert into debtor_statement_icd10 (ifkAccountID,sTarrifCode,sDaggerCode,
												iStatementLineNumber,iLineNumber,ifkOperatorID,ifkICD10ID) 
                                                select viAccID,sTarrifCode,sDaggerCode,vicdlinenum,iLineNumber,ifkOperatorID,ifkICD10ID 
                                                    from account_fee_icd10
													where ifkAccountID = viAccID and iFeeLineNumber = v_iFeeLine;
                                                    
				SELECT GROUP_CONCAT(i.sICD10Code SEPARATOR  ',') into v_sDiagnosesCodes FROM debtor_statement_icd10 d,icd_10 i
				where ifkaccountid = viAccID
				and iStatementLineNumber = vicdlinenum 
				and i.ipkICD10ID = d.ifkICD10ID
				order by iLineNumber;              
                
                update debtor_statement_audit set sDiagnosesCodes = v_sDiagnosesCodes where iTransactionLineNumber = vicdlinenum and ifkAccountID = viAccID;
           end; end if;
     
    SET done = FALSE ; 
	END LOOP read_loop_fees;
        
	CLOSE fees;
      
	  set vDateDiffDays =  datediff(current_timestamp(),vAccDateEntered);
	  select ipkAgeID into vAgeID from debtor_age_groups where iAgeDaysStart <= vDateDiffDays and iAgeDaysEnd >= vDateDiffDays;
			
	  CALL DebtorSetAddionalInfo(viAccID, vAgeID,0);
	  call DebtorAutoAssignOperatorToAccount(viAccID);
	  INSERT INTO debtor_comments (ipkDebtorCommentID,sComment,dDateEntered,ifkAccountID,ifkCapturedBy) ( select 0,tComment,dDateLastUpdated,ifkAccountID,v_operatorid from account_comments where ifkAccountID = viAccID);	  
      update accounts set bDebtorAccount = 1 where ipkAccountid = viAccID;
	  call DebtorUpdateVisitTotals(viAccID);
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

