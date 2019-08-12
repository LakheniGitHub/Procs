use `promed`;
drop procedure if exists `DebtorReceiptVoid`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `DebtorReceiptVoid`(in vrctid bigint)
begin

  /*  
  developer : johannes pretorius
  date : 28 feb 2018
  purpose : servers as a relay to debtorreceiptadd as it the same type of call needed but done for better CODE writing purposes
  */
  call debtorreceiptadd(vrctid);
  
end$$

delimiter ;

