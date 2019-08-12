use `promed`;
drop procedure if exists `AccessionCreateSelect`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `AccessionCreateSelect`(in iAccountID bigint)
begin
     declare vsacc varchar(10);
     declare vtel int;
     declare vsuid varchar(64);
	 declare vstartstatus bigint;
	 declare vstartstatusgroup bigint;
	 declare  oiAccessionID bigint;
	 declare  osAccessionNumber varchar(15);
	 
declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[acs]:',MSG),1,128);   	
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
     
     call AccessionCreate(iAccountID,oiAccessionID,osAccessionNumber);
	 select oiAccessionID,osAccessionNumber;
		
     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
end; end if;             
     
end$$

delimiter ;

