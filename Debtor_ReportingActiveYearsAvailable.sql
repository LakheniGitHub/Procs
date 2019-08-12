use `promed`;
drop procedure if exists `Debtor_ReportingActiveYearsAvailable`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingActiveYearsAvailable`()
begin
  select distinct(iRunFiscalYear) as vyear from debtor_statement_audit;
end$$

delimiter ;

