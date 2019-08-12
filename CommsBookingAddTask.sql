use `promed`;
drop procedure if exists `CommsBookingAddTask`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsBookingAddTask`(in tasktype varchar(30),
								in ibookingid  bigint,
								in refdocid bigint,
                                in execute_date timestamp,
                                in additional1 varchar(100),
                                in additional2 varchar(100),
                                in additional3 varchar(100),
                                in additional4 varchar(100)
                                )
begin
/*
task type (in booking_comms_task and booking_comms_task_additional table)
===========
sms_reMINder
sms_confirmation
email_reMINder
email confirmation

additional1 - additional4
===========================
is used depending on the task type, can be additional NUMBERs sms is send to or additional email it is send to
*/
   declare vtid bigint;
   /*declare vtargetcell varchar(20);*/

  insert into booking_comms_task (ipkCommTaskID,sTaskType,ifkBookingID,ifkReferringDoctorID,dTriggerDate,iErrorOccured,iHandled,dDateEntered,sError)
			 values (0, tasktype, ibookingid, refdocid, execute_date, 0, 0, current_timestamp, '');
 
 set vtid = last_insert_id();
 
 insert into booking_comms_task_additional (ifkCommTaskID, sAdditional1,sAdditional2,sAdditional3,sAdditional4) values (vtid,additional1,additional2,additional3,additional4);

end$$

delimiter ;

