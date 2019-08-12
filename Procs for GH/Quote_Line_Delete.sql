use `promed`;
drop procedure if exists `Quote_Line_Delete`;

delimiter $$
use `promed`$$
create procedure `Quote_Line_Delete` (in ventryid bigint)
begin
declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[qld]:',MSG),1,128);   	
		rollback;
    set @g_transaction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  delete from  quote_lines where ipkQuteLineID = ventryid;
  
if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  
end$$

delimiter ;

