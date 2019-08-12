use `promed`;
drop procedure if exists `CommsAddTask`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsAddTask`(in tasktype varchar(30),
								in accountid  bigint,
								in refdocid bigint,
                                in execute_date timestamp,
                                in additional1 varchar(100),
                                in additional2 varchar(100),
                                in additional3 varchar(100),
                                in additional4 varchar(100),
								in vtargetcell varchar(20),
                                in iacccessionid bigint
                                )
begin
/*
task types
============
fax_report_patient
fax_report_doctor
fax_recall_list
fax_recall_patient

email_recall_list
email_recall_patient
email_report_patient
email_report_doctor

print_recall_list
print_recall_patient
print_report

sms_patient
sms_member
sms_doctor

additional1 - additional4
===========================
is used depending on the task type, can be additional NUMBERs sms is send to or additional email it is send to
*/
   declare vtid bigint;

  insert into comms_task (ipkCommTaskID,sTaskType,ifkAccountID,ifkReferringDoctorID,dTriggerDate,iErrorOccured,iHandled,dDateEntered,sError,ifkAccessionID)
			 values (0, tasktype, accountid, refdocid, execute_date, 0, 0, current_timestamp, '',iacccessionid);
 
 set vtid = last_insert_id();
 if (tasktype = 'email_report_patient') and (additional1 = '') then begin
   select p.sEmail into additional1 from accounts a,patients p 
					where a.ipkAccountID = accountid 
                    and a.ifkPatientID  = p.ipkPatientID;
 end; end if;
 
 if (tasktype = 'email_report_doctor') and (additional1 = '') then begin
   select r.sEmail into additional1 from accounts a,referring_doctors r 
				where a.ipkAccountID = accountid 
                and a.ifkPrimaryReferringDoctorID  = r.ipkReferringDoctorID;
 end; end if;


 insert into comms_task_additional (ifkCommTaskID, sAdditional1,sAdditional2,sAdditional3,sAdditional4,sTargetCell) values (vtid,additional1,additional2,additional3,additional4,vtargetcell);

end$$

delimiter ;

