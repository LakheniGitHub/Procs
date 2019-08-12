drop procedure if exists `CaptureBookingExam`;

delimiter $$
create definer=`root`@`localhost` procedure `CaptureBookingExam`(vbookingid int(11),
	in vexamCODE varchar(20))
begin
	declare vexamid bigint;
    
    select ipkExamID into vexamid from exams where sExamCode = vexamCODE;
    
	insert into booking_exams(ifkBookingID, ifkExamID)
	values(vbookingid, vexamid);
end$$
delimiter ;
