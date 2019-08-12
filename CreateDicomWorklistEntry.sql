drop procedure CreateDicomWorklistEntry;

delimiter $$
create definer=`root`@`localhost` procedure `CreateDicomWorklistEntry`(in vaccountcode varchar(10),in vaccessionid bigint)
begin

    declare vstudyid bigint;
    declare vpatientname varchar(64);
    declare vpatientdateofbirth varchar(10);
    declare vpatientid varchar(64);
    declare vstudydate varchar(10);
    declare vpatientuid varchar(64);
    declare vstudydescription varchar(64);
    declare vstudyinstanceuid varchar(64);
    declare vexamid bigint;
	declare vexamname varchar(100);
	declare vexamramscode varchar(15);
	declare vexamlinenumber  integer;
    declare vaccountid bigint;
    declare vmodalityid bigint;
    declare vreferringdoctorid bigint;
    declare vhospitalnumber varchar(20);
	declare vhospitaldoc smallint;
    declare vward varchar(30);
	declare vwardid bigint;
    declare vdatecreated timestamp;
    declare vsex varchar(3);
    declare vdoctorgroup varchar(50);
    declare vdoctormedia varchar(10);
    declare vreferringdoctorcode varchar(10);
    declare vreferringdoctoname varchar(100);	
    declare vlocalsite varchar(3);
    declare vaccountsiteid varchar(3);
    declare vtempcount integer;
    declare vidnumber varchar(13);
    declare vtelwork char(1);
    declare vtriggercheck integer;
	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[cdwe]:',MSG),1,128);   	
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
    version / weergawe : 1.0
    update date / opdateer datum : 3 feb 2009
    */
    
    /*kry rekening informasie*/
   
    set vdatecreated = current_timestamp;
    select ipkAccountID into vaccountid from accounts a where a.sAccountCode = vaccountcode;

    call runtriggercheck('DP', vtriggercheck);
            
    if (vtriggercheck = 0) then
		set vidnumber = vpatientid;
    end if;
    

	/*begin - die deel moet met vase 2 verander dat dit die */
	/* sudie id wat on patient exams gestoor gaan word neem*/

	/*         - word vervang  - trek die id van die patient ondersoek tafel af
		select skep_studie_uid(1) from pms_config into :vstudyinstanceuid; 
	*/

	call createstudyuidproc(1,vstudyinstanceuid);

	set vtempcount = 0;

	select count(dwl.ipkDicomWorklistID)
	into vtempcount
	from   dicom_worklist dwl
	where  dwl.sStudyInstanceUID = vstudyinstanceuid;

	if (vtempcount > 0) then
		call createstudyuidproc(1,vstudyinstanceuid);
	end if;
	
	select ipkAccountID,ifkPrimaryReferringDoctorID,bHospitalDoctor,replace(cast(cast(dExamDate as date) as char(10)), '-', ''),sHospitalNumber,ifkWardID,sDoctorMedia
			into vaccountid,vreferringdoctorid,vhospitaldoc,vstudydate,vhospitalnumber ,vwardid,vdoctormedia
			from accounts where sAccountCode = vaccountcode;
			
	select concat(sSurname, ' ', sInitials, ' ', sTitle) into vreferringdoctoname  from referring_doctors where ipkReferringDoctorID = vreferringdoctorid;
	select ifkExamID,ifkModalityID,iLineNumber into vexamid,vmodalityid,vexamlinenumber from account_exams  where ifkaccountID = vaccountid and ifkaccessionID = vaccessionid order by ipkAccountExamID desc limit 1;
	select sName,sRAMSCode into vexamname,vexamramscode from exams where ipkExamID = vexamid;
	
	if (vexamlinenumber <> 10) then begin
	  select sDescription into vexamname from rams_structure_detail  where sRAMSCode = vexamramscode and iLineNumber = vexamlinenumber limit 1;
	end; end if;
	
	if (vhospitaldoc = 1) then begin
	  set vreferringdoctoname = 'HOSPITAL';
	end; end if;
	
	

		if not exists (select ipkDicomWorklistID from dicom_worklist dwl where ifkaccountID = vaccountid and ifkaccessionID = vaccessionid) then
		begin

			insert into dicom_worklist(	dStudyDate, sStudyDescription, sStudyInstanceUID, ifkExamID, ifkaccountID,
										ifkModalityID, ifkReferringDoctorID, sHospitalNumber, ifkWardID, dDateCreated,
										sDoctorGroup, sDoctorMedia,ifkaccessionID) 
									values
                 (vstudydate,vexamname,	vstudyinstanceuid,vexamid,vaccountid,vmodalityid,vreferringdoctorid,vhospitalnumber,vwardid,current_timestamp,vreferringdoctoname,vdoctormedia,vaccessionid);
		end;
	end if;
        
	update dicom_worklist dwl
		set	dwl.dStudyDate = vstudydate,
			dwl.sStudyDescription = vexamname,
			dwl.ifkModalityID = vmodalityid,
			dwl.ifkReferringDoctorID = vreferringdoctorid,
			dwl.sHospitalNumber = vhospitalnumber,
			dwl.ifkWardID = vwardid,
			dwl.sDoctorGroup = vreferringdoctoname,
			dwl.sDoctorMedia = vdoctormedia,
			dwl.bComplete = 0,
            dwl.bDeleted = 0,
            dwl.iHandled = 0,
            dwl.ifkExamID = vexamid,
			dwl.ifkaccessionID  = vaccessionid
	where ifkaccountID = vaccountid and ifkaccessionID = vaccessionid ;
       if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if; 	
end$$
delimiter ;
