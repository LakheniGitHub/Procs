drop procedure if exists `CancelAccession`;

delimiter $$
create definer=`root`@`localhost` procedure `CancelAccession`(in vaccountcode varchar(10),
									in vaccession varchar(15),
									in vusername varchar(15),
									in vnote varchar(500))
begin

	declare vtelw integer;
    declare vaccessid bigint;
	declare vaccid bigint;
	declare vopid bigint;
    declare vdicomstatusid integer;
	declare vAssCount integer;
	declare vCancelCount  integer;
    declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[CAs]:',MSG),1,128);   	
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
   
	select ipkOperatorID into vopid from operators o where o.sUserName = vusername;
	select aa.ipkAccessionID into vaccessid from account_accessions aa where aa.sAccessionNumber = vaccession;
	select ds.ipkDicomStatusID into vdicomstatusid from dicom_statuses ds where ds.sDicomStatus = 'DISCONTINUED';
	select ipkAccountID into vaccid from accounts a where a.sAccountCode = vaccountcode;
	
	update account_accessions aa
	set 	aa.ifkCancelledByOperatorsID = vopid,
            aa.bActive = 0,
            aa.iLockedBy = null,
            aa.sNote = vnote
	where  	aa.ipkAccessionID = vaccessid; 

	update dicom_worklist dwl
	set    ifkDicomStatusID = vdicomstatusid
	where  ifkaccessionID = vaccessid;
	

	/*update operators o
	set    o.ifkCurrentAccountID = null
	where  o.ifkCurrentAccountID = (select ipkAccountID from accounts a where a.sAccountCode = vaccountcode);*/

	set vtelw = 0;

	/*update bookings b
		set b.bActive = 0,
			b.ifkoperatorcancelledid = (select ipkOperatorID from operators o where o.sUserName = vusername)
	where  b.ifkaccountID = (select ipkAccountID from accounts a where a.sAccountCode = vaccountcode);*/

    call runtriggercheck('hc', @vtelw);

	if (@vtelw = 1) then
		call hl7addtask(vaccountcode, 'cancel', vusername, '', vaccessid);
	end if;
	select count(ipkAccessionID) into vAssCount from account_accessions where ifkAccountID =  vaccid;
	select count(ipkAccessionID) into vCancelCount from account_accessions where ifkAccountID =  vaccid and bActive = 0;
	
	if (vAssCount = vCancelCount) then begin
	   call CancelAccount(vaccountcode,vusername,vnote);
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
