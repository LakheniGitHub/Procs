use `promed`;
drop procedure if exists `Debtor_Transfer`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_Transfer`(in v_isourceaccountid bigint, 
															  in v_itargetaccountid bigint,
															  in v_famount decimal(18,2),
															  in v_fvatamount decimal(18,2),
															  in v_capturedby bigint,
															  in v_batchnumber varchar(20),
															  in vpayer varchar(50),
													          in vmop bigint )
begin
/* 
 developer : johannes pretorious
 date : 7 maart 2018
 purpose : to transfer a specific amount (credit) from one account to another.
 do check first if there is credit to transfer
 
 NOTE : need to get a valid vat amount from accounts in future for vat PERCENTAGE (v_ftaxpercentage)
  
*/

    declare  v_debtortype bigint;
    declare v_taxtype integer;
    declare v_srcbalance decimal(18,2);
    declare v_ftaxpercentage decimal(18,2);
	declare v_suspendlinenum integer;
	declare v_suspendid bigint;
    
    declare v_tmpbalance decimal(18,2);
    declare v_srcacccode varchar(10);
    declare v_trgacccode varchar(10);
    declare v_istatementid bigint;
 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dt]:',MSG),1,128);   	
		rollback;
    set @g_transaction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  set autocommit = 0;
   if ((@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
     start transaction;  
     set @g_transaction_started = 1;
   end; else begin
    set @g_transaction_started = @g_transaction_started + 1;
   end; end if;
 
    select fBalance,sAccountCode into v_srcbalance,v_srcacccode from accounts where ipkAccountID = v_isourceaccountid;
    
	
    set v_tmpbalance = -1 * v_srcbalance;
    
    if ((v_tmpbalance > 0) and (v_tmpbalance >= (v_famount + v_fvatamount))) then begin
	   select ipkTaxType,fTaxPercentage into v_taxtype,v_ftaxpercentage from debtor_taxes where sTaxCode = 'vat';
       select ipkDebtorTransactionType into v_debtortype from debtor_transaction_types where sTransactionTypeCode = 'trnsfr';    
   	   if (v_itargetaccountid > 0) then begin /*is not suspense account*/
		 select sAccountCode into v_trgacccode from accounts where ipkAccountID = v_itargetaccountid;   
		 /*call debtorsuspenslineadd('', current_timestamp,'transfer', concat('transfer to ',v_trgacccode), -1 * v_famount,current_timestamp,v_capturedby,null,v_isourceaccountid,null, v_suspendid);*/
		 /*select iBatchItemNumber into v_suspendlinenum from debtor_suspense where ipkDebtorSuspensID = v_suspendid;*/
	   
		 call debtorstatementlineadd(v_debtortype, v_taxtype,v_isourceaccountid, current_timestamp,1,concat('transfer to ',v_trgacccode), '', '',  v_famount,
									 v_fvatamount, v_ftaxpercentage, '', v_capturedby, v_batchnumber, null,'',vpayer,null,null, v_istatementid);
		 call debtoreventcapture(v_isourceaccountid, v_capturedby, 'transfer', concat('transfer to ',v_trgacccode),null);
		 
		 /*call debtorsuspenslineadd('', current_timestamp,'transfer', concat('transfer from ',v_srcacccode), v_famount,current_timestamp,v_capturedby,null,v_itargetaccountid,null, v_suspendid);								 */
		 call debtorstatementlineadd(v_debtortype, v_taxtype,v_itargetaccountid, current_timestamp,1,concat('transfer from ',v_srcacccode), '', '',  -1 * v_famount,
									 -1 * v_fvatamount, v_ftaxpercentage, '', v_capturedby, v_batchnumber, null,'',vpayer,null,null, v_istatementid);     
         call debtoreventcapture(v_itargetaccountid, v_capturedby, 'transfer', concat('transfer from ',v_srcacccode),null);									 
		 
		 call debtorupdatevisittotals(v_isourceaccountid);
		 call debtorupdatevisittotals(v_itargetaccountid);
	  end; else begin
	      set v_trgacccode = 'suspense';
		 /*call debtorsuspenslineadd('', current_timestamp,'transfer', concat('transfer to ',v_trgacccode), -1 * v_famount,current_timestamp,v_capturedby,null,v_isourceaccountid,null, v_suspendid);*/
		 /*select iBatchItemNumber into v_suspendlinenum from debtor_suspense where ipkDebtorSuspensID = v_suspendid;*/
	   
		 call debtorstatementlineadd(v_debtortype, v_taxtype,v_isourceaccountid, current_timestamp,1,concat('transfer to ',v_trgacccode), '', '',  v_famount,
									 v_fvatamount, v_ftaxpercentage, '', v_capturedby, v_batchnumber, null,'',vpayer,null,null, v_istatementid);
         call debtoreventcapture(v_isourceaccountid, v_capturedby, 'transfer', concat('transfer to ',v_trgacccode),null);									 
		 
         call debtor_suspenseaccountentryadd(concat('transfer from ',v_srcacccode),v_capturedby,'acnttransfer',current_timestamp,v_famount,v_batchnumber,vpayer,vmop,v_istatementid);
		 call debtorupdatevisittotals(v_isourceaccountid);
      end; end if;	  
    end; else begin
			signal sqlstate '45000'
			set message_text = "source account has insufficient funds for transfer.";       
    end; end if;

     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
end$$

delimiter ;

