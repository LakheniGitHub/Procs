delimiter $$
create definer=`root`@`localhost` procedure `CommsDeleteTask`(in vcommtaskid int)
begin

	delete ct from comms_task ct
	where ct.ipkCommTaskID = vcommtaskid;

	delete cta from comms_task_additional cta
	where cta.ifkCommTaskID = vcommtaskid;

end$$
delimiter ;
