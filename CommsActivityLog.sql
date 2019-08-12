use `promed`;
drop procedure if exists `CommsActivityLog`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsActivityLog`(in vrefNUMBER varchar(15),
									in vtasktype varchar(20),
                                    in vtcell varchar(20), 
                                    in vtemail varchar(100),
                                    in vMSG varchar(255),
                                    in vcommid bigint)
begin
  /*
    johannes
    16 jun 2018
    purpose  : store activity in comms back to system
    
    vcommid will be what was passed with the comms xml. based on booking or account id one must link it back to
    comms_task or booking_comms_task yourself
  */
  
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
sms_doctor
*/
 declare vid bigint;
  declare viaccount bigint;
  declare vibooking bigint;
  declare vimatched int;
  
  set vid = null;
  set vimatched = 0;
  set viaccount = 0;
  set vibooking = 0;
  
  select ipkAccountID into vid from accounts where sAccountCode = vrefNUMBER;
  
  if ((vid > 0) and (vid is not null)) then begin
    /*found account*/
    set vimatched = 1;
    set viaccount = vid;
  end; else  begin
    set vid = null;
    select ipkBookingID into vid from bookings where sBookingCode = vrefNUMBER;
    if ((vid > 0) and (vid is not null)) then begin
       set vibooking = vid;
       set vimatched = 1;
    end; end if;
  end; end if;  
 insert into comms_activity (ipkCommsActivityID,sRef_number,sTaskType,sTargetCell,sTargetEmail,sMessage,
							ifkAccountID,ifkBookingID,dDateEntered,ifkCommsID)
							values
						(0,vrefNUMBER,vtasktype,vtcell,vtemail,vMSG,
						viaccount,vibooking,current_timestamp,vcommid);

end$$

delimiter ;

