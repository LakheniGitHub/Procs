delimiter $$
create definer=`root`@`localhost` procedure `CancelledWard`(out vWARD varchar(5))
begin

select CODE into vWARD from WARDs where DESCRIPTION = 'cancelled';

end$$
delimiter ;
