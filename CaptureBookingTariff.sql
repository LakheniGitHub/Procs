drop procedure if exists `CaptureBookingTariff`;

delimiter $$
create definer=`root`@`localhost` procedure `CaptureBookingTariff`(vbookingid int(11),
	in vtariff varchar(20))
begin
	insert into booking_tariffs(ifkBookingID, sTariffCode)
	values(vbookingid, vtariff);
end$$
delimiter ;
