use `promed`;
drop procedure if exists `Debtor_BadDebtSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_BadDebtSave`(in vlistid bigint,
										in vaccid bigint,
										in vcaptureidby bigint, 
                                        in vbaddebtdate date, 
                                        in vamount decimal(18,2), 
                                        in vvatamount decimal(18,2), 
                                        in vlisted smallint,
											in v_addDate timestamp)
begin
  declare vpid bigint;
  declare vmid bigint;  
  declare vexist bigint;  

 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dbds]:',MSG),1,128);   	
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
  select ifkPatientID,ifkMemberID into vpid ,vmid from accounts where ipkAccountID = vaccid;
  
  if ((vlistid is null) or (vlistid <=0)) then begin  
          insert into debtor_baddebt (ipkDebtorBadDebtID,dDateEntered,ifkAccountID,ifkPatientID,ifkMemberID,fAmount,bListed,dListDate,fVatAmount,ifkCapturedByID)
            values
			(0,v_addDate,vaccid,vpid,vmid,vamount,vlisted,vbaddebtdate,vvatamount,vcaptureidby);

  end; else begin
		update debtor_baddebt set
			bListed = vlisted,
			dListDate = vbaddebtdate
			where ipkDebtorBadDebtID = vlistid;
  end; end if;
  update debtor_additional set bBadDebt = vlisted where ifkAccountID = vaccid;  
  
       if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
end$$

delimiter ;

