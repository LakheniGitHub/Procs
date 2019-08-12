use `promed`;
drop procedure if exists `Debtor_AddPayment`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AddPayment`(in v_accountid bigint, 
																in v_debtortype integer,
																in v_amount decimal(18,2),
																in v_batchNUMBER varchar(10),
																in v_sPaidBy varchar(80),
																in v_sDescription varchar(100),
																in v_dPaymentDatetime timestamp ,
																in v_capturedby bigint,
																in v_imethodofpayment integer,
																in v_receiptCODE varchar(10),
											in v_addDate timestamp)
begin

 /*  
  developer : johannes pretorius
  date : 8 maart 2018
  purpose : to allow payments to be added against account via other means than receipt.alter
  
  NOTE : the question needs to be answered if the system is suppose to then create a receipt entry for this type or not (in receipt table)
  
  if v_batchNUMBER is blank a batch NUMBER will be generated for payment
  */
	/*declare voPCODE varchar(10);*/
	
    
    declare v_taxtype integer;
    
    declare  v_fTaxPERCENTAGE decimal(18,2);
    declare v_stmtid bigint;
    declare v_suspendid bigint;
    declare v_suspendLINEnum integer;
	declare vbal decimal(18,2);
	declare vsmallbalauto decimal(18,2);
	
 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dap]:',MSG),1,128);   	
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
 
   /*select sOperatorCode into voPCODE  from operators where ipkOperatorID =  v_capturedby;*/
   
   if (v_batchNUMBER = '') then begin
     call DebtorDailyReceiptBatchNUMBER(v_capturedby,v_batchNUMBER);
   end; end if;  
   
   if (v_batchNUMBER = 'none') then begin
			signal sqlstate '45000'
			set message_text = "opertor receipt batch not setup yet. please setup before continue.";   
   end; end if;
   
	if (v_amount > 0) then begin
	  set v_amount = -1 * v_amount;
	end; end if;
     
   select ipkTaxType,fTaxPERCENTAGE into v_taxtype,v_fTaxPERCENTAGE from debtor_taxes where sTaxCode = 'vat';

  /*rememer suspense LINE is oppsite what is going into statement*/
   /*call DebtorSuspensLINEAdd(v_batchNUMBER, current_timestamp,v_sPaidBy, v_sDescription, -1 * v_amount,v_dPaymentDatetime,v_capturedby,null,v_accountid,v_imethodofpayment, v_suspendid);
   select iBatchItemNUMBER into v_suspendLINEnum from debtor_suspense where ipkDebtorSuspensID = v_suspendid;
*/
   call DebtorStatementLINEAdd(v_debtortype,v_taxtype,v_accountid,v_dPaymentDatetime,1,v_sDescription,'','',v_amount,0,v_fTaxPERCENTAGE,'',
							  v_capturedby,v_batchNUMBER,v_suspendLINEnum,v_receiptCODE,v_sPaidBy,null,v_imethodofpayment,v_addDate,v_stmtid);
   call DebtorEventCapture(v_accountid, v_capturedby, 'payment', v_sDescription,null,v_addDate);									 							  
   call DebtorUpdateVisitTotals(v_accountid);
   select a.fBalance,dc.fAuto_SB_Writeoff into vbal,vsmallbalauto from accounts a ,sites s ,debtor_practice_info dc where a.ifkSiteID = s.ipkSiteID  and s.ifkPracticeInfoID  = dc.ifkPracticeInfoID and a.ipkAccountID = v_accountid;
   
   if ((vbal <= vsmallbalauto) and (vbal > 0)) then begin
      call Debtor_SmallBalanceWriteOff(v_accountid,v_capturedby,'auto',v_batchNUMBER,v_addDate);     
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

