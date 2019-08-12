use `promed`;
drop procedure if exists `CommsAddRecall`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsAddRecall`(in iaccountid bigint, in iAccession bigint,in dtrigdate timestamp,in sexamtype varchar(100))
begin
/*
  author : johannes
  
  date : 14 nov 2017
  
  purpose : to save a recalls against the account to be send to the doctor and patients as required for the trigger date and examtype
  
  currently examtype has no purpose as we use the exam from the Accession given.
  
  types used
===========
fax_recall_list
fax_recall_patient
email_recall_list
email_recall_patient
print_recall_list
print_recall_patient

uses 
call CommsAddTask(in tasktype varchar(30),in accountid  bigint,in refdocid bigint,in execute_date timestamp,in additional1 varchar(100),in additional2 varchar(100),in additional3 varchar(100),in additional4 varchar(100),in iacccessionid bigint)

*/
declare vbReceiveRecall integer;
declare vbPatientRecall integer;
declare vbReportEmail integer;
declare vbReportfax integer;
declare vbReportPrint integer;
declare vbReportBluebird integer;
declare vbPrintCopies integer;
declare vsCellphone varchar(15);
declare vsFax varchar(15);
declare vscomsspref varchar(15);
declare vsEmail    varchar(255);

declare vpri_refdocid bigint;
declare vsec_refdocid bigint;
declare vP_ID bigint;

declare vprinted  smallint;
declare vprecallprinted  smallint;
declare vcounter integer;
 
 set vprinted = 0;
 set vprecallprinted = 0;
  
  
  select ifkPatientID,ifkPrimaryReferringDoctorID,ifkSecondaryReferringDoctorID 
		into vP_ID,vpri_refdocid,vsec_refdocid 
	from accounts 
    where ipkAccountID = iaccountid;
  
  select bReceiveRecall,bPatientRecall,bReportEmail,bReportfax,bReportPrint,bReportBluebird,bPrintCopies,sCellphone,sEmail,sFax 
		into vbReceiveRecall,vbPatientRecall,vbReportEmail,vbReportfax,vbReportPrint,vbReportBluebird,vbPrintCopies,vsCellphone,vsEmail,vsFax
	from referring_doctors 
    where ipkReferringDoctorID = vpri_refdocid;
   

    if (vbReceiveRecall = 1) then begin
		if ((vbReportEmail = 1) and (vsEmail <> '')) then begin
		  call CommsAddTask('email_recall_list',iaccountid,vpri_refdocid,dtrigdate,vsEmail,'','','','',iAccession);
		end; end if;

		if ((vbReportfax = 1) and (vsFax <> '')) then begin
		  call CommsAddTask('fax_recall_list',iaccountid,vpri_refdocid,dtrigdate,vsFax,'','','','',iAccession);
		end; end if;

		if (vbReportPrint = 1) then begin
			call CommsAddTask('print_recall_list',iaccountid,vpri_refdocid,dtrigdate,'','','','','',iAccession);
		end; end if;
    end; end if;    
     
    if (vbPatientRecall = 1) then begin
         set vscomsspref = '';
         set vsEmail = '';
         set vsFax = '';
         set vsCellphone  = '';
         
          select sEmail,upper(sComsPreference),sFax ,sCellphone  
				into vsEmail, vscomsspref,vsFax,vsCellphone 
			from  patients 
            where ipkPatientID = vP_ID and bConsent = 1;

        if ((vscomsspref = 'email') and (vsEmail <> '')) then begin
            call CommsAddTask('email_recall_patient',iaccountid,vpri_refdocid,dtrigdate,vsEmail,'','','','',iAccession);     
        end; end if;
        if ((vscomsspref = 'sms') and (vsEmail <> '')) then begin
            /*call CommsAddTask('email_recall_patient',iaccountid,vpri_refdocid,dtrigdate,vsEmail,'','','',iAccession);     */
        end; end if;
        if ((vscomsspref = 'post') ) then begin
            call CommsAddTask('print_recall_patient',iaccountid,vpri_refdocid,dtrigdate,'','','','','',iAccession);     
        end; end if;
        set vprecallprinted = 1;
    end; end if;
    
    if (vpri_refdocid != vsec_refdocid) then begin
          /*basic repeat of above for doc*/
		  select bReceiveRecall,bPatientRecall,bReportEmail,bReportfax,bReportPrint,bReportBluebird,bPrintCopies,sCellphone,sEmail,sFax 
				into vbReceiveRecall,vbPatientRecall,vbReportEmail,vbReportfax,vbReportPrint,vbReportBluebird,vbPrintCopies,vsCellphone,vsEmail,vsFax
			from referring_doctors 
			where ipkReferringDoctorID = vsec_refdocid;
			
			if (vbReceiveRecall = 1) then begin
				if ((vbReportEmail = 1) and (vsEmail <> '')) then begin
				  call CommsAddTask('email_recall_list',iaccountid,vsec_refdocid,dtrigdate,vsEmail,'','','','',iAccession);
				end; end if;

				if ((vbReportfax = 1) and (vsFax <> '')) then begin
				  call CommsAddTask('fax_recall_list',iaccountid,vsec_refdocid,dtrigdate,vsFax,'','','','',iAccession);
				end; end if;

				if ((vbReportPrint = 1) ) then begin
					call CommsAddTask('print_recall_list',iaccountid,vsec_refdocid,dtrigdate,'','','','','',iAccession);
				end; end if;
           end; end if;   
			if ((vprecallprinted = 0) and (vbPatientRecall = 1)) then begin
				 set vscomsspref = '';
				 set vsEmail = '';
				 set vsFax = '';
				 set vsCellphone  = '';
				 
				  select sEmail,upper(sComsPreference),sFax ,sCellphone  
						into vsEmail, vscomsspref,vsFax,vsCellphone 
					from  patients 
					where ipkPatientID = vP_ID and bConsent = 1;
				
				if ((vscomsspref = 'email') and (vsEmail <> '')) then begin
					call CommsAddTask('email_recall_patient',iaccountid,vpri_refdocid,dtrigdate,vsEmail,'','','','',iAccession);     
				end; end if;
				if ((vscomsspref = 'sms') and (vsEmail <> '')) then begin
					/*call CommsAddTask('email_recall_patient',iaccountid,vpri_refdocid,dtrigdate,vsEmail,'','','',iAccession);     */
				end; end if;
				if ((vscomsspref = 'post') ) then begin
					call CommsAddTask('print_recall_patient',iaccountid,vpri_refdocid,dtrigdate,'','','','','',iAccession);     
				end; end if;
			end; end if;           
    end; end if;


end$$

delimiter ;

