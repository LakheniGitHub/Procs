use `promed`;
drop procedure if exists `Debtor_HandoverSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_HandoverSave`(in vlistid bigint,
										in vaccid bigint,
										in vcaptureidby bigint, 
                                        in vhandoverdate date, 
                                        in vhandoverto bigint, 
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
    set MSG = substring(concat('[dhos]:',MSG),1,128);   	
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
          insert into Debtor_HandOver (ipkHandOverID,ifkAccountID,ifkCapturedBy,fAmount,fVat,ifkHandOverToID,dDateEntered,dHandOverDate,bListed,ifkPatientID,ifkMemberID)
			           values
                                 (0,vaccid,vcaptureidby,vamount,vvatamount,vhandoverto,v_addDate,vhandoverdate,1,vpid,vmid);
  end; else begin
		update Debtor_HandOver set
				ifkCapturedBy = vcaptureidby,
				ifkHandOverToID = vhandoverto,
				dHandOverDate = vhandoverdate,
				bListed = vlisted
			where ipkHandOverID = vlistid;
  
  end; end if;
  update debtor_additional set bHandOver = vlisted where ifkAccountID = vaccid;  
commit;

end$$

delimiter ;

