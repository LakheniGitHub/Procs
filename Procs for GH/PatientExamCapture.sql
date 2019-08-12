use `promed`;
drop procedure if exists `PatientExamCapture`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `PatientExamCapture`(in vaccountcode varchar(8),
									in vmodalitycode varchar(20),
                                    in vexamcode varchar(20),
                                    in vroomcode varchar(10),
                                    in vexamdate datetime,
                                    in vaccessionid bigint)
begin
	declare vaccountexamdate datetime;
    declare vaccountid bigint;
    declare vmodalityid bigint;
    declare vexamid bigint;
    declare vroomid bigint;
    declare vaccountexamid bigint;
    declare vaccessid bigint;
    declare vsaccess varchar(15);
    declare vusername varchar(30);
    
    declare vtel int;
	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[pec]:',MSG),1,128);   	
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

	set vexamdate = ifnull(vexamdate, current_timestamp);
    select ipkAccountID,sUserName into vaccountid,vusername from accounts a where a.sAccountCode = vaccountcode;
    select ipkModalityID into vmodalityid from modalities mo where mo.sModalityCode = vmodalitycode;
    select ipkExamID into vexamid from exams e where e.sExamCode = vexamcode;
    select ipkRoomID into vroomid from rooms r where r.sRoomCode = vroomcode;
    
    if (vexamdate = '0000-00-00') then	begin
			set vexamdate = current_timestamp;
    end; end if;
	
    select count(ipkAccessionID) into vtel from account_accessions where ipkAccessionID = vaccessionid;
    set vaccessid = vaccessionid;
    if (vtel = 0) then begin
        call accessioncreate(vaccountid,vaccessid,vsaccess);
    end; end if;
    if not exists (select ipkAccountExamID from account_exams where ifkaccountID = vaccountid and ifkaccessionID = vaccessid and ifkExamID = vexamid) then begin
		insert into account_exams(ifkaccountID, 
									ifkModalityID, 
									ifkExamID, 
									ifkRoomID, 
									dExamDate,ifkaccessionID)     values(vaccountid,vmodalityid,vexamid,vroomid,vexamdate,vaccessid);
         set vaccountexamid =  last_insert_id();
         update account_exams  set iRef = vaccountexamid	where ipkAccountExamID = vaccountexamid;         
   
   
		select dExamDate into vaccountexamdate from accounts a where a.ipkAccountID = vaccountid;
		
		if ((vaccountexamdate is null) or (vaccountexamdate = '0000-00-00')) then
			update accounts a set a.dExamDate = vexamdate where a.ipkAccountID = vaccountid;
		else
			if (vaccountexamdate < (select MIN(ae.dExamDate) from accounts a inner join account_exams ae on ae.ifkaccountID = a.ipkAccountID where a.ipkAccountID = vaccountid)) then
				begin

					update accounts a set a.dExamDate = (select MIN(ae.dExamDate) from account_exams ae where ae.ifkaccountID = a.ipkAccountID) where a.ipkAccountID = vaccountid;
				end;
			end if;
		end if;

		call createdicomworklistentry(vaccountcode,vaccessid);
		call hl7control(vaccountcode, 'update', '',vaccessid);
        if not exists (select ipkEligibilityTransationID from promed.elig_transactions where ifkaccountID = vaccountid ) then begin
           call EligSilentSubmitPV(vaccountcode, vusername);
        end; end if;

		insert into promed_logs.operator_access_log(dAccessTimestamp, sAccessType)
		values(current_timestamp, 'exam capture');
        call log_accessionexamchange(vaccessid);
    end; else begin
	/*
	  make sure exams on account is set to lowest exam date on accessions (accession can have diff exam dates)
	*/
	  select MIN(ae.dExamDate) into vaccountexamdate from account_exams ae where ae.ifkaccountID = vaccountid;
	  update account_exams  set dExamDate = vexamdate where ifkaccountID = vaccountid and ifkaccessionID = vaccessid;
  	  update accounts a set a.dExamDate = vaccountexamdate where a.ipkAccountID = vaccountid;
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

