use `promed`;
drop procedure if exists `CommsAddReportAuthed`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsAddReportAuthed`(in iaccountid bigint,in iAccession bigint )
begin

/*
auth : johannes

date : 14 nov 2017

purpose : to find the ref doc comms pref if any are email,fax or print then a commes entry is created for the report to be 
emailed or faxed to ref doc on this. if there are 2 ref docs, for now both is checked and there comms pREFERENCE send. 
when implemented (future)
if the patient has a email or fax pREFERENCE it will also be scheduled to send to them. print just done on ref docs pREFERENCE

types used
===========
fax_report_patient
fax_report_doctor
email_report_patient
email_report_doctor
print_report

uses 
call CommsAddTask(in tasktype varchar(30),in accountid  bigint,in refdocid bigint,in execute_date timestamp,in additional1 varchar(100),in additional2 varchar(100),in additional3 varchar(100),in additional4 varchar(100),in iacccessionid bigint)
*/

declare vbReceiveRecall integer;
declare vbPatientRecall integer;
declare vbReportEmail integer;
declare vbReportfax integer;
declare viBranchid integer;
declare vbReportPrint integer;
declare vbReportBluebird integer;
declare vbPrintCopies integer;
declare vsCellphone varchar(15);
declare vsFax varchar(15);
declare vsEmail    varchar(255);
declare vprinter varchar(255);

declare vpri_refdocid bigint;
declare vsec_refdocid bigint;
declare vP_ID bigint;

declare vprinted  smallint;
declare vcounter integer;
 
 set vprinted = 0;

  select ifkPatientID,ifkPrimaryReferringDoctorID,ifkSecondaryReferringDoctorID ,ifkBranchID
		into vP_ID,vpri_refdocid,vsec_refdocid ,viBranchid
	from accounts 
    where ipkAccountID = iaccountid;
	
	select ifnull(sPrinter,'') into vprinter from Branches where ipkBranchID = viBranchid;
  
  select bReceiveRecall,bPatientRecall,bReportEmail,bReportfax,bReportPrint,bReportBluebird,bPrintCopies,sCellphone,sEmail,sFax 
		into vbReceiveRecall,vbPatientRecall,vbReportEmail,vbReportfax,vbReportPrint,vbReportBluebird,vbPrintCopies,vsCellphone,vsEmail,vsFax
	from referring_doctors 
    where ipkReferringDoctorID = vpri_refdocid;
    
    if (vbPrintCopies <= 0 ) then set vbPrintCopies = 1; end if;
	if (vbPrintCopies >= 10 ) then set vbPrintCopies = 1; end if;
	
    if ((vbReportEmail = 1) and (vsEmail <> '')) then begin
      call CommsAddTask('email_report_doctor',iaccountid,vpri_refdocid,current_timestamp,vsEmail,'','','','',iAccession);
    end; end if;

    if ((vbReportfax = 1) and (vsFax <> '')) then begin
      call CommsAddTask('fax_report_doctor',iaccountid,vpri_refdocid,current_timestamp,vsFax,'','','','',iAccession);
    end; end if;

    if (vbReportPrint = 1) then begin
      if ((vprinter is not null) and (vprinter <> ''))  then begin
		  set vcounter = 1;   
		  select vbPrintCopies;
		  while (vcounter <= vbPrintCopies) do
			 select vcounter;
			call CommsAddTask('print_report',iaccountid,vpri_refdocid,current_timestamp,'','','','','',iAccession);
			set vcounter = vcounter +  1;   
		  end while;  
	  end; end if;	   
      set vprinted = 1;
    end; end if;

    if (vbReportBluebird = 1) then begin
      /*todo dunno if still needed */
      /*call CommsAddTask('print_report',iaccountid,vpri_refdocid,current_timestamp,'','','','',iAccession);*/
    end; end if;
    
    if (vpri_refdocid != vsec_refdocid) then begin
          /*basic repeat of above for doc*/
		  select bReceiveRecall,bPatientRecall,bReportEmail,bReportfax,bReportPrint,bReportBluebird,bPrintCopies,sCellphone,sEmail,sFax 
				into vbReceiveRecall,vbPatientRecall,vbReportEmail,vbReportfax,vbReportPrint,vbReportBluebird,vbPrintCopies,vsCellphone,vsEmail,vsFax
			from referring_doctors 
			where ipkReferringDoctorID = vsec_refdocid;
			if (vbPrintCopies <= 0 ) then set vbPrintCopies = 1; end if;
			if (vbPrintCopies >= 10 ) then set vbPrintCopies = 1; end if;
			
			if ((vbReportEmail = 1) and (vsEmail <> '')) then begin
			  call CommsAddTask('email_report_doctor',iaccountid,vsec_refdocid,current_timestamp,vsEmail,'','','','',iAccession);
			end; end if;

			if ((vbReportfax = 1) and (vsFax <> '')) then begin
			  call CommsAddTask('fax_report_doctor',iaccountid,vsec_refdocid,current_timestamp,vsFax,'','','','',iAccession);
			end; end if;

			if ((vbReportPrint = 1) and (vprinted = 0)) then begin
			  if ((vprinter is not null) and (vprinter <> ''))  then begin
				  set vcounter = 1;   
				  while (vcounter <= vbPrintCopies) do
					call CommsAddTask('print_report',iaccountid,vsec_refdocid,current_timestamp,'','','','','',iAccession);
					set vcounter = vcounter +  1;   
				  end while;  
			  end; end if;	  
			  set vprinted = 1;
			end; end if;

			if (vbReportBluebird = 1) then begin
			  /*todo dunno if still needed */
			  /*call CommsAddTask('print_report',iaccountid,vsec_refdocid,current_timestamp,'','','','',iAccession);*/
			end; end if;
    
    end; end if;
end$$

delimiter ;

