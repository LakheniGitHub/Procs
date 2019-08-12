use `promed`;
drop procedure if exists `Debtor_EligSetProcessed`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_EligSetProcessed`(in vaccid bigint,
											in vcapturedby bigint,
											in v_addDate timestamp)
begin
   update debtor_additional set iEligProcessed = 1 where ifkAccountID = vaccid;
   call DebtorEventCapture(vaccid, vcapturedby, 'ELIG', 'ELIG set to processed',null,v_addDate);									 
end$$

delimiter ;

