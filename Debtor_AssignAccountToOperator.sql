use `promed`;
drop procedure if exists `Debtor_AssignAccountToOperator`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AssignAccountToOperator`(in vaccid bigint,in voperatorid bigint)
begin
  update debtor_additional set ifkAssignedID = voperatorid where ifkAccountID = vaccid;
  /*need to add loging of assing history*/
end$$

delimiter ;

