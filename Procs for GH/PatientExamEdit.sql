use `promed`;
drop procedure if exists `PatientExamEdit`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `PatientExamEdit`(in vaccountid bigint,
                                    in vaccessionid bigint,
                                    in vexamdate datetime)
begin
	declare vaccountexamdate datetime;
	declare MSG varchar(128);
	
    declare exit handler for sqlexception
	begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[ped]:',MSG),1,128);   	
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
      
	/*
	  make sure exams on account is set to lowest exam date on accessions (accession can have diff exam dates)
	*/
    update account_exams set dExamDate = vexamdate
	where ifkaccountID = vaccountid and ifkaccessionID = vaccessionid;

	
	select MIN(ae.dExamDate) into vaccountexamdate from account_exams ae
	where ae.ifkaccountID = vaccountid;
    
	update accounts a set a.dExamDate = vaccountexamdate where a.ipkAccountID = vaccountid;

    insert into promed_logs.operator_access_log(dAccessTimestamp, sAccessType)
	values(current_timestamp, 'exam edit');

    call log_accessionexamchange(vaccessionid);
	     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
end$$

delimiter ;

