use `promed`;
drop procedure if exists `Debtor_SmallBalanceWriteOff`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_SmallBalanceWriteOff`(in v_accountid bigint,
									in v_capturedby bigint,
									in vtype varchar(20),
									in vbatchnumber varchar(20))
begin
/*
     developer : johannes pretorius
     date : 15 oct 2018
     purpose : small balance writeoff , triggered by configured values for practice.
   */
    declare  v_debtortype bigint;
    declare v_taxtype integer;
    declare v_srcbalance decimal(18,2);
    declare v_ftaxpercentage decimal(18,2);
	declare v_ftaxpmultiply  decimal(18,2);
    declare v_fvatamount decimal(18,2);
	declare  v_fvatexclamount  decimal(18,2);
    declare v_famount decimal(18,2);
    declare v_description varchar(100);
    
    declare v_srcacccode varchar(10);
    declare v_istatementid bigint;
	declare v_vatcharge integer;
 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dsmbwo]:',MSG),1,128);   	
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
 
    set v_fvatamount = 0.0;

    select fBalance,sAccountCode into v_srcbalance,v_srcacccode from accounts where ipkAccountID = v_accountid;
    
    
    if (v_srcbalance > 0)  then begin
	     select ipkTaxType,fTaxPercentage,fTaxMultiplyFactor into v_taxtype,v_ftaxpercentage,v_ftaxpmultiply from debtor_taxes where sTaxCode = 'vat';
        set v_famount = v_srcbalance;
		set v_fvatexclamount = v_srcbalance;
		
        set v_description = concat(vtype,' small balance writeoff amount : ',v_srcbalance);
        select ipkDebtorTransactionType,v_vatcharge into v_debtortype,v_vatcharge from debtor_transaction_types where sTransactionTypeCode = 'smallwoff';
		if (v_vatcharge = 1) then begin
		  set v_fvatamount = v_famount - (v_famount / v_ftaxpmultiply);
		  set v_fvatexclamount = v_famount - v_fvatamount;
		end; end if;		
        
        call debtor_writeoff(v_accountid,v_description,v_famount,v_capturedby,v_debtortype,vbatchnumber);
        /*call debtoreventcapture(v_accountid, v_capturedby, 'smallwoff', v_description,null);	*/
		call debtor_addcomment(concat(ifnull(v_description,'')),v_accountid,v_capturedby);
    end; else begin
			signal sqlstate '45000'
			set message_text = "writeoff value larger than account balance.";       
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

