use `promed`;
drop procedure if exists `Debtor_AccountRemoveFromBadDebt`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AccountRemoveFromBadDebt`(in v_accountid bigint)
begin

 /*
  NOTE : only gets called when a reverse blacklist/ handover / baddebt is called
 */

 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[datbd]:',MSG),1,128);   	
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
 
/*
  this must change to a soft delete in the future if possible and adding a account to bad debt will just undelete it then
  */
   delete from bad_debts where ifkAccountID = v_accountid;

	
	     if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
end$$

delimiter ;

