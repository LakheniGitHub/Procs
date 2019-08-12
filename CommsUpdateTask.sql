delimiter $$
create definer=`root`@`localhost` procedure `CommsUpdateTask`(in vcommtaskid int,
								in tasktype varchar(30),
								in refdocid integer,
                                in execute_date timestamp,
                                in additional1 varchar(100),
                                in additional2 varchar(100),
                                in additional3 varchar(100),
                                in additional4 varchar(100))
begin

	update comms_task ct
		set sTaskType = ifnull(tasktype, sTaskType),
			ifkReferringDoctorID = ifnull(refdocid, ifkReferringDoctorID),
			dTriggerDate = ifnull(execute_date, dTriggerDate)
	where ct.ipkCommTaskID = vcommtaskid;

	update comms_task_additional cta
		set sAdditional1 = ifnull(additional1, sAdditional1),
			sAdditional2 = ifnull(additional2, sAdditional2),
			sAdditional3 = ifnull(additional3, sAdditional3),
			sAdditional4 = ifnull(additional4, sAdditional4)
	where cta.ifkCommTaskID = vcommtaskid;

end$$
delimiter ;
