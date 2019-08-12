use `promed`;
drop procedure if exists `Debtor_BlackListSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_BlackListSave`(in vlistid bigint,
										in vaccid bigint,
										in vcaptureidby bigint, 
                                        in vblacklistdate date, 
                                        in vamount decimal(18,2), 
                                        in vvatamount decimal(18,2), 
                                        in vlisted smallint)
begin
  declare vpid bigint;
  declare vmid bigint;  
  declare vexist bigint;  

 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dbls]:',MSG),1,128);   	
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
  select ifkPatientID,ifkMemberID into vpid ,vmid from accounts where ipkAccountID = vaccid;
  
  if ((vlistid is null) or (vlistid <=0)) then begin
          insert into debtor_blacklist (ipkBlackListID,dDateEntered,ifkaccountID,ifkPatientID,ifkMemberID,fAmount,bListed,dDateListed,fVATAmount)
            values
			(0,current_timestamp,vaccid,vpid,vmid,vamount,vlisted,vblacklistdate,vvatamount);

  end; else begin
		update debtor_blacklist set
			bListed = vlisted,
			dDateListed = vblacklistdate
			where ipkBlackListID = vlistid;
  end; end if;
  update debtor_additional set bBlackListed = vlisted where ifkaccountID = vaccid;
       if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;  
end$$

delimiter ;

