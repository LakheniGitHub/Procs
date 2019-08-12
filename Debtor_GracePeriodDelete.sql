use `promed`;
drop procedure if exists `Debtor_GracePeriodDelete`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_GracePeriodDelete`(in ventryid bigint)
begin
  delete from debtor_graceperiod where ipkDebtorGracePeriodID = ventryid;
end$$

delimiter ;

