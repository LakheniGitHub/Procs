use `promed`;
drop procedure if exists `EligSilentSubmitPV`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `EligSilentSubmitPV`(in vaccountcode varchar(15),
								in vusername varchar(50))
begin
	declare vsuccess integer;
	declare vexists integer;
	declare veligt varchar(2);
	declare vmember integer;
	declare vactive integer;
	declare vmsgtypeto char(1);
    declare vaccountid integer;

	/* on success return 1 , else 0 */
    	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[esspv]:',MSG),1,128);   	
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
   
	set vsuccess = 1;
    
	set vexists = 0;

	select 	es.ipkEligibilityStatusID, 
			a.ifkMemberID,
            /*map.sOptionName,*/
            map.bActive,
            map.sEligibility,
            map.sPV,
            a.ipkAccountID
    into 	vexists,
			vmember,
            /*vmedplan,*/
            vactive,
            veligt,
            vmsgtypeto,
            vaccountid
    from accounts a
    left join elig_statuses es
		on es.ipkEligibilityStatusID = a.ifkEligibilityStatusID
	left join members m
		on m.ipkMemberID = a.ifkMemberID
	left join medical_aid_plan map
		on map.ipkMedicalAidPlanID = m.ifkMedicalAidPlanID
    where a.sAccountCode = vaccountcode;

	if ((vactive = 1) and (vmsgtypeto = 'y')) then 
		begin
			/* -- johannes 17 aug 2016 0 laat PV herstuur ongeag of voorheen al het
			if ((bestaan = 0) or (bestaan is null) or (bestaan = 102) or (bestaan = 103) or (bestaan = 100) or (bestaan = 106))  then 

			begin*/
           
			if (veligt = '') then 
					select PC.sElig 
                    from pms_config PC
                    into veligt;
			end if;
           
			update accounts a
				set a.ifkEligibilityStatusID = 1 
			where a.ipkAccountID = vaccountid;
           
			select count(ipkEligibilityTransationID) 
            into vexists
            from elig_transactions 
				where ifkaccountID = vaccountid;
            
			
            if (vexists = 0) then 
				insert into elig_transactions (ifkaccountID,sPatientValidationUser,dPatientValidationDate,iPatientValidationStatus,sEligibilityType) 
                values (vaccountid,vusername,current_timestamp,0,veligt);
			else 
				update elig_transactions
					set sPatientValidationUser = vusername, 
						iPatientValidationStatus = 0, 
                        dPatientValidationDate = current_timestamp 
					where ifkaccountID = vaccountid;
			end if;

			insert into elig_transaction_messages (ifkaccountID,sMessageType,iMessageStatus,dMessageDate,sUserName,sMessage) 
			values (vaccountid,'PV',0,current_timestamp,vusername,'patient validationd submitted');
		end; 
	else 
		set vsuccess = 0;
	end if;
    	     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  
/*    select vsuccess;*/
end$$

delimiter ;

