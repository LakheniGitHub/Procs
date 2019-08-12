USE `promed`;
DROP procedure IF EXISTS `CapturePatientHistory`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CapturePatientHistory`(IN vPatientUID VARCHAR(64),
																IN vHistory LONGTEXT)
BEGIN
    declare vExist integer;
    declare vPatID bigint;
    declare vPatHistID bigint;
    declare vTmpHist longtext;
    
    select ipkPatientID into vPatID from patients where  sUID = vPatientUID;
    
    SELECT COUNT(ipkPatientHistoryID) into vExist FROM patient_history  where ifkPatientID  = vPatID;

	IF (vExist > 0)
		THEN 
			BEGIN
                SELECT ipkPatientHistoryID,tHistory into vPatHistID,vTmpHist FROM patient_history  where ifkPatientID  = vPatID;
                /*Original line was with carriage return inside it, thus left the same*/
                set vTmpHist = CONCAT(IFNULL(vTmpHist,''), " 
                ", vHistory);
                
				UPDATE patient_history  
					SET tHistory = vTmpHist,
						dDateLastUpdated = CURRENT_TIMESTAMP
				WHERE ipkPatientHistoryID = vPatHistID;

			END;
	ELSE
		BEGIN

			INSERT INTO patient_history(ifkPatientID, sPatientUID, tHistory)
            VALUES (vPatID, vPatientUID, vHistory);

		END;
	END IF;

END$$

DELIMITER ;

