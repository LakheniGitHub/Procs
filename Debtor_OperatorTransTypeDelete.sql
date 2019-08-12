use `promed`;
drop procedure if exists `Debtor_OperatorTransTypeDelete`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_OperatorTransTypeDelete`(in voperatorid bigint, in vtransType bigint)
begin
  /*
    NOTE if transType is null then all entries will be deleted against operator else only the one entry
  */
  
  if (vtransType < 0) then begin
     delete from debtor_operators_transAction_types where  ifkOperatorID = voperatorid;
  end; else begin
     delete from debtor_operators_transAction_types where  ifkOperatorID = voperatorid and   ifkDebtorTransActionType = vtransType;
  end; end if;
  
end$$

delimiter ;

