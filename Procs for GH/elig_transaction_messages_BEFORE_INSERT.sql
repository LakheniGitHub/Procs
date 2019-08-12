DROP TRIGGER IF EXISTS `promed`.`elig_transaction_messages_BEFORE_INSERT`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `promed`.`elig_transaction_messages_BEFORE_INSERT` BEFORE INSERT ON `elig_transaction_messages` FOR EACH ROW
BEGIN
   declare vDebtorAcc integer;
   declare vStsMsg varchar(15);
   
   if (new.ifkAccountid is not null) then begin
     select bDebtorAccount into vDebtorAcc  from accounts where ipkAccountID = new.ifkAccountid;
     if (vDebtorAcc = 1) then begin
        select ets.sStatusName into vStsMsg from  elig_transaction_statuses ets where ets.iStatusNumber = new.iMessageStatus;
        update debtor_additional set iEligStatusNumber = new.iMessageStatus,sEligStatus = vStsMsg,sEligStatusMessage = new.sMessage,iEligProcessed = 0
        where ifkAccountID = new.ifkAccountid;
     end; end if;
   end;  end if;
END$$
DELIMITER ;
