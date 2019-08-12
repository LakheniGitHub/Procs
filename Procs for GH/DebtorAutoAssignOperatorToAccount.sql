use `promed`;
drop procedure if exists `DebtorAutoAssignOperatorToAccount`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `DebtorAutoAssignOperatorToAccount`(in vaccid bigint)
begin

  declare vopid bigint;
 declare done boolean default 0;
   declare MSG varchar(128);
  declare continue handler for sqlstate '02000' set done = 1;    
  declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[dsai]:',MSG),1,128);   	
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
   
  select ifkOperatorID into vopid from debtor_operators_cfg where bDebtorAutoAssign = 1 order by dDebtorLastAssignDate asc limit 1;
  
  call debtor_assignaccounttooperator(vaccid, vopid);
  
  update debtor_operators_cfg set dDebtorLastAssignDate = current_timestamp() where ifkOperatorID = vopid;
  
  
       if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if; 
end$$

delimiter ;

