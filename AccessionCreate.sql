USE `promed`;
DROP procedure IF EXISTS `AccessionCreate`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AccessionCreate`(IN iAccountID BIGINT, OUT oiAccessionID BIGINT, OUT osAccessionNumber varchar(15))
BEGIN
     declare vsAcc varchar(10);
     declare vtel INT;
     declare vsuid varchar(64);
declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[AC]:',msg),1,128);   	
			ROLLBACK;
    set @G_transaction_started = 0;
		signal sqlstate '45000' SET MESSAGE_TEXT = msg;
	 END;
      SET autocommit = 0;
   if ((@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
     START TRANSACTION;  
     set @G_transaction_started = 1;
   end; else begin
    set @G_transaction_started = @G_transaction_started + 1;
end; end if;
     
     
     select sAccountCode into vsAcc from accounts where ipkAccountID = iAccountID;
     select count(ipkAccessionID) into vtel from account_accessions where ifkAccountID = iAccountID;
     CALL CreateStudyUIDProc(1,vsuid);
     
     set vtel = vtel + 1;
     set osAccessionNumber = concat(vsAcc,'A',vtel);

     
     insert into account_accessions (ipkAccessionID,ifkAccountID,sAccessionNumber,sSUID,dDateEntered) values (0,iAccountID,osAccessionNumber,vsuid,CURRENT_TIMESTAMP);
     set oiAccessionID = LAST_INSERT_ID();
     update db_stats set IAccessionCount = IAccessionCount + 1;

     INSERT INTO visit(ifkAccountID, dExaminationDate, dDateEntered, sUserName,ifkAccessionID)
            VALUES(iAccountID, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SYSTEM',oiAccessionID);
     if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
end; end if;             
     
END$$

DELIMITER ;

