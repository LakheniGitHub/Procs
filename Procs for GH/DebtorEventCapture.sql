use `promed`;
drop procedure if exists `DebtorEventCapture`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `DebtorEventCapture`(in vaccountid bigint,in voperatorid bigint,in veventcode varchar(20), in vcomment varchar(150),in vdocimgid bigint)
begin
  declare ienvtid bigint;
 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dec]:',MSG),1,128);   	
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
  
  select ipkDebtorEventID into ienvtid from debtor_event_types where sEventCode = veventcode;
  
  insert into debtor_events (ipkDebtorEventID,ifkaccountID,ifkOperatorID,ifkEventTypeID,sComment,ifkdoc_id) values
              (0,vaccountid,voperatorid,ienvtid,vcomment,vdocimgid);
     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;

end$$

delimiter ;

