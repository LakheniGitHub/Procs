use `promed`;
drop procedure if exists `HL7AddTask`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `HL7AddTask`( in vaccountcode varchar(10),
                                    in vtask varchar(10),
                                    in vuser varchar(15),
                                    in vmergeaccountcode varchar(10),in vaccessionid bigint)
begin
    declare vopid varchar(5);
    declare vexists smallint;
    declare vaccountid bigint;
    declare vmergeaccountid bigint;
declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[hat]:',MSG),1,128);   	
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
   

    set vaccountid = (select ipkAccountID from accounts a where a.sAccountCode = vaccountcode);
    set vmergeaccountid = (select ipkAccountID from accounts a where a.sAccountCode = vmergeaccountcode);

  if (vaccountid is not null) then begin
        insert into hl7_sending_list (sUser, ifkaccountID, sTaskType, ifkMergeAccountID, ifkaccessionID) /*ifkHL7OptionID*/
        values (vuser, vaccountid, vtask, vmergeaccountid, vaccessionid); /*0,*/
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

