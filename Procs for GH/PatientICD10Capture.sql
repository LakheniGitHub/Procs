USE `promed`;
DROP procedure IF EXISTS `PatientICD10Capture`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `PatientICD10Capture`(IN vAccountCode VARCHAR(8),
									IN vOperatorCode VARCHAR(4),
                                    IN vICD10Code VARCHAR(10),
                                    IN vLineNumber INTEGER,
                                    IN vDateEntered DATETIME,
                                    IN vTarrifCode VARCHAR(10),
                                    IN vFeeLineNumber INT,
                                    IN vLinked TINYINT,
                                    IN vRefDoc TINYINT,
                                    IN vFeeLine TINYINT,
                                    IN vPatientID bigint)
BEGIN
 
	 declare vICD10ID bigint;
	 declare vAccID bigint;
	 declare vOperatorID bigint;
	 declare vLoggedIn integer;
	 
	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[PiC]:',msg),1,128);   	
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
    
	IF NOT EXISTS (SELECT ipkICD10ID FROM icd_10 I WHERE I.sICD10Code = vICD10Code) THEN
		BEGIN

			INSERT INTO icd_10(sICD10Code, bCustom)
            VALUES (vICD10Code, 1);
        END;
	END IF;
    
	SELECT ipkICD10ID into vICD10ID FROM icd_10 I WHERE I.sICD10Code = vICD10Code;
	SELECT ipkAccountID into vAccID FROM accounts A WHERE A.sAccountCode = vAccountCode;
	SELECT ipkOperatorID,bLoggedIn into vOperatorID,vLoggedIn FROM operators O WHERE O.sOperatorCode = vOperatorCode;
	
	IF(IFNULL(vRefDoc,0) <> 0) THEN
		BEGIN
 
			IF NOT EXISTS (SELECT ipkAccountRefDocICD10ID
							FROM account_refdoc_icd10
                            WHERE ifkAccountID = vAccID
								AND ifkICD10ID = vICD10ID) THEN
				BEGIN
 
					INSERT INTO account_refdoc_icd10(ifkAccountID, 
													ifkOperatorID, 
													ifkICD10ID, 
													iLineNumber, 
													dDateEntered)
					VALUES(vAccID, 
							vOperatorID,
							vICD10ID,
							vLineNumber,
							vDateEntered);
				END;
			END IF;
		END;
	END IF;

	IF(IFNULL(vFeeLine,0) <> 0) THEN
		BEGIN

			IF NOT EXISTS (SELECT ipkAccountFeeICD10ID 
							FROM account_fee_icd10
                            WHERE ifkAccountID = vAccID
								AND iFeeLineNumber = vFeeLineNumber
                                AND ifkICD10ID = vICD10ID) THEN
				BEGIN

					INSERT INTO account_fee_icd10(ifkAccountID,
													sTarrifCode,
													ifkICD10ID,
													iFeeLineNumber,
													iLineNumber,
													ifkOperatorID,
													bLinked)
					VALUES(vAccID,
							vTarrifCode,
							vICD10ID,
							vFeeLineNumber,
							vLineNumber,
							vOperatorID,
							vLinked);
				END;
			END IF;
		END;
	END IF;
    
    IF(IFNULL(vPatientID, 0) <> 0) THEN
		BEGIN

			INSERT INTO patient_icd10(ifkICD10ID, ifkPatientID)
			VALUES(vICD10ID, vPatientID);
        END;
	END IF;

    INSERT INTO promed_logs.operator_access_log(ifkOperatorID, dAccessTimestamp, sAccessType, bLogIn)
	            VALUES(vOperatorID, CURRENT_TIMESTAMP, 'ICD10 Capture', vLoggedIn);
				
  if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
END$$

DELIMITER ;
