use `promed`;
drop procedure if exists `CaptureBookingICD10`;

delimiter $$
use `promed`$$
create procedure `CaptureBookingICD10`(vbookingid int(11),
	in vicd10 varchar(10))
begin
	insert into booking_icd10(ifkBookingID, sICD10Code)
	values(vbookingid, vicd10);
end$$

delimiter ;

