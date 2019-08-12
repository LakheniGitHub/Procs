use `promed`;
drop procedure if exists `Debtor_OperatorTransTypeSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_OperatorTransTypeSave`(in voperatorid bigint, in vtranstype bigint)
begin
   /*
     NOTE the sp does not clear or delete, just insert if it does not exist yet. this table has all those operator is allowed to see
     if any is not allowed, they must be remvoed from table
   */
   
   declare vexist integer;
   
   select count(*) into vexist from debtor_operators_transaction_types where ifkOperatorID  = voperatorid and ifkDebtorTransactionType = vtranstype;
   
   if ((vexist is null) or (vexist <= 0 )) then begin
      insert into debtor_operators_transaction_types (ipkDebtorOperatorTransTypeID, dDateEntered, ifkOperatorID, ifkDebtorTransactionType)
           values
          (0, current_timestamp,voperatorid,vtranstype);

      
   end; end if;
end$$

delimiter ;

