use `promed`;
drop procedure if exists `Debtor_FinalNoticePrinted`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_FinalNoticePrinted`(in vaccid bigint)
begin
    update debtor_additional set bFinalNotice = 1 where ifkAccountID = vaccid;
    
    /*
      return something as we want to call this from a report and it must return a result
    */
    select vaccid;
    
end$$

delimiter ;

