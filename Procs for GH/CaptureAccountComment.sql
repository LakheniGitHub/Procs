USE `promed`;
DROP procedure IF EXISTS `CaptureAccountComment`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CaptureAccountComment`(IN vAccountCode VARCHAR(15),
																IN vComment LONGTEXT)
BEGIN
declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[CAC]:',msg),1,128);   	
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

	IF ((SELECT COUNT(AC.ipkAccountCommentID) FROM account_comments AC INNER JOIN accounts A ON A.ipkAccountID = AC.ifkAccountID WHERE A.sAccountCode = vAccountCode) > 0)
		THEN 
			BEGIN

				UPDATE account_comments AC 
                INNER JOIN accounts A 
					ON A.ipkAccountID = AC.ifkAccountID
					SET AC.tComment = CONCAT(IFNULL(AC.tComment,''), "

", vComment),
						AC.dDateLastUpdated = CURRENT_TIMESTAMP
				WHERE A.sAccountCode = vAccountCode;

			END;
	ELSE
		BEGIN

			INSERT INTO account_comments(ifkAccountID, tComment)
            VALUES ((SELECT A.ipkAccountID FROM accounts A WHERE A.sAccountCode = vAccountCode), vComment);

		END;
	END IF;
         if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
end; end if; 

END$$

DELIMITER ;

