use `promed`;
drop procedure if exists `CaptureReportInfo`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CaptureReportInfo`(in vaccountCODE varchar(8),
                                                                in vbirad1 varchar(80),
                                                                in vbirad1left varchar(3),
                                                                in vbirad1right varchar(3),
                                                                in vbirad2 varchar(80),
                                                                in vbirad2left varchar(3),
                                                                in vbirad2right varchar(3),
                                                                in vrecall integer,
                                                                in vrecalldays1 integer,
                                                                in vrecallMSG1 varchar(150),
                                                                in vrecalldays2 integer,
                                                                in vrecallMSG2 varchar(150),in vAccessionid bigint)
begin
     
     declare viacc bigint;
     declare vded timestamp;
     
     select ipkAccountID,dExamDate into viacc,vded from accounts where sAccountCode = vaccountCODE;
	if not exists (select ipkReportInfoID from report_info ri inner join accounts a on a.ipkAccountID = ri.ifkAccountID where a.ipkAccountID = viacc and ri.ifkAccessionID = vAccessionid) then		begin
			insert into report_info (sRecallMessage,
									sRecallMessage2,
									ifkAccountID,
									iRecallDays,
									iRecall,
									iRecallDays2,
									sBiRad1,
									sBiRad1L,
									sBiRad1R,
									sBiRad2,
									sBiRad2L,
									sBiRad2R,ifkAccessionID)
			values(vrecallMSG1,
					vrecallMSG2,
					viacc,
					vrecalldays1,
					vrecall,
					vrecalldays2,
					vbirad1,
					vbirad1left,
					vbirad1right,
					vbirad2,
					vbirad2left,
					vbirad2right,vAccessionid);
        
	end; else begin
			update report_info ri
			set ri.sRecallMessage = vrecallMSG1,
				ri.sRecallMessage2 = vrecallMSG2,
				ri.iRecallDays = vrecalldays1,
				ri.iRecall = vrecall,
				ri.iRecallDays2 = vrecalldays2,
				ri.sBiRad1 = vbirad1,
				ri.sBiRad1L = vbirad1left,
				ri.sBiRad1R = vbirad1right,
				ri.sBiRad2 = vbirad2,
				ri.sBiRad2L = vbirad2left,
				ri.sBiRad2R = vbirad2right
			where ri.ifkAccountID = viacc and ri.ifkAccessionID = vAccessionid;
	end; end if;
	if (vrecall = 1)  then begin
		/*set iHandled = 5 to reset those already scehduled but changed befored triggered.*/
		update comms_task set iHandled = 5 
			where ifkAccountID = viacc 
				and ifkAccessionID = vAccessionid 
				and iHandled = 0 
				and sTaskType in ('fax_recall_list','fax_recall_patient','email_recall_list','email_recall_patient','print_recall_list','print_recall_patient');
	   call CommsAddRecall(viacc,vAccessionid,date_add(current_timestamp,interval vrecalldays1 day),vbirad1); /*vded*/
	   if (vrecalldays2 > 0) then begin
			call CommsAddRecall(viacc,vAccessionid,date_add(current_timestamp,interval vrecalldays2 day),vbirad2);
	   end; end if;
	end; end if;    
end$$

delimiter ;

