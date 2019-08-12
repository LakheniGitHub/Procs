use `promed`;
drop procedure if exists `Debtor_BadDebtWriteOff`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_BadDebtWriteOff`(in v_accountid bigint,in v_capturedby bigint,
									in vbatchNUMBER varchar(20),
											in v_addDate timestamp)
begin

   /*
     developer : johannes pretorius
     date : 8 maart 2018
     purpose : to writeoff baddebt on account
     
     NOTE need to add bad debt operation (adding to bad debt table etc)
   */
    declare  v_debtortype bigint;
    declare v_taxtype integer;
    declare v_srcbalance decimal(18,2);
    declare v_fTaxPERCENTAGE decimal(18,2);
    declare v_fVatAmount decimal(18,2);
    declare v_fAmount decimal(18,2);
    declare v_DESCRIPTION varchar(100);

	declare v_ftaxpmultiply  decimal(18,2);
	declare  v_fVatexclamount  decimal(18,2);
	declare v_vatcharge integer;
    
    declare v_srcaccCODE varchar(10);
    declare v_iStatementid bigint;
 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dho]:',MSG),1,128);   	
		rollback;
    set @g_transAction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  set autocommit = 0;
   if ((@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
     start transAction;  
     set @g_transAction_started = 1;
   end; else begin
    set @g_transAction_started = @g_transAction_started + 1;
   end; end if;    
    set v_fVatAmount = 0.0;

    select fBalance,sAccountCode into v_srcbalance,v_srcaccCODE from accounts where ipkAccountID = v_accountid;
    
    
    if (v_srcbalance > 0)  then begin
	     select ipkTaxType,fTaxPERCENTAGE,fTaxMultiplyFactor into v_taxtype,v_fTaxPERCENTAGE,v_ftaxpmultiply from debtor_taxes where sTaxCode = 'vat';	
        set v_fAmount = v_srcbalance;
		set v_fVatexclamount = v_srcbalance;
		
        set v_DESCRIPTION = concat('bad debt writeoff for amount : ',(v_fAmount ));
		
        select ipkDebtorTransActionType,bVatCharge into v_debtortype,v_vatcharge  from debtor_transAction_types where sTransactionTypeCode = 'badwoff';
		if (v_vatcharge = 1) then begin
		  set v_fVatAmount = v_fAmount - (v_fAmount / v_ftaxpmultiply);
		  set v_fVatexclamount = v_fAmount - v_fVatAmount;
		end; end if;		
		
        
        call Debtor_AccountToBadDebt(v_accountid, 0, 0, v_capturedby);
		call Debtor_WriteOff(v_accountid,v_DESCRIPTION,v_fAmount,v_capturedby,v_debtortype,vbatchNUMBER,v_addDate);
        
        call DebtorEventCapture(v_accountid, v_capturedby, 'baddebt', v_DESCRIPTION,null,v_addDate);	
		call Debtor_BadDebtSave(0,v_accountid, v_capturedby,current_timestamp,v_fAmount,v_fVatAmount,1,v_addDate);
		call Debtor_AddComment(concat('bad debt - ',ifnull(v_DESCRIPTION,'')),v_accountid,v_capturedby,v_addDate);		
       /*
	   select ipkTaxType,fTaxPERCENTAGE into v_taxtype,v_fTaxPERCENTAGE from debtor_taxes where sTaxCode = 'vat';
   
     


     call DebtorStatementLINEAdd(v_debtortype, v_taxtype,v_accountid, current_timestamp,1,v_DESCRIPTION, '', '',  -1 * v_fAmount,
								 v_fVatAmount, v_fTaxPERCENTAGE, '', v_capturedby, '', null, v_iStatementid);
     call DebtorUpdateVisitTotals(v_accountid);
     */
    end; else begin
			signal sqlstate '45000'
			set message_text = "writeoff value larger than account balance.";       
    end; end if;
     if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
end$$

delimiter ;

