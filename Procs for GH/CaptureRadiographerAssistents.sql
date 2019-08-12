USE `promed`;
DROP procedure IF EXISTS `CaptureRadiographerAssist`;		/*no longer in use*/
DROP procedure IF EXISTS `CaptureRadiographerAssistents`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CaptureRadiographerAssistents`(IN vAccessionID BIGINT,
																	IN vOperatorID BIGINT)
BEGIN
    /*declare vOperatorID bigint;
    select ipkOperatorID into vOperatorID from operators  where sOperatorCode = vOperatorCode;*/
    
	IF EXISTS (SELECT ipkRadiographerAssistedAccessionID 
				FROM radiographer_assisted_accessions RAA 
                WHERE RAA.ifkOperatorID = vOperatorID and RAA.ifkAccessionID = vAccessionID ) THEN
		BEGIN

			
        END; 
	ELSE
		BEGIN

			INSERT INTO radiographer_assisted_accessions(ifkOperatorID, ifkAccessionID)
            VALUES(vOperatorID, vAccessionID);
        END;
	END IF;
END$$

DELIMITER ;

