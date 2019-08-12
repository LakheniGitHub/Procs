USE `promed`;
DROP procedure IF EXISTS `OperatorCapture`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `OperatorCapture`(IN vOperatorTypeId INT,
															IN vOperatorCode VARCHAR(4),
                                                            IN vUserName varchar(15),
															IN vPswd VARCHAR(15),
                                                            IN vTitle varchar(5),
															IN vInitials VARCHAR(5),
															IN vFirstNames varchar(255), 
															IN vLastName varchar(100) ,
															IN vActive tinyint(4))
BEGIN
    IF EXISTS(select ipkOperatorID from operators where sOperatorCode = vOperatorCode) THEN  
		BEGIN
        
			UPDATE operators O
				SET ifkOperatorTypeID = vOperatorTypeId,
					sUserName = vUserName,
					sPswd = vPswd,
                    sTitle = vTitle,
					sInitials = vInitials,
					sFirstNames = vFirstNames,
					sLastName = vLastName,
					bActive = vActive
			WHERE sOperatorCode = vOperatorCode;
            
			UPDATE operators O
			SET ifkSettingsID = (select ipkSettingsID from prism_settings as PS where PS.sCode = vOperatorCode)
			WHERE O.sOperatorCode = vOperatorCode;              
            
		END;
	ELSE
		BEGIN 
    
			INSERT INTO operators(ifkOperatorTypeID,
								sOperatorCode,
								sPswd,
                                sTitle,
								sInitials,
								sFirstNames,
								sLastName,
								sUserName,
								bActive)
			VALUES(vOperatorTypeId,
					vOperatorCode,
					vPswd,
                    vTitle,
					vInitials,
					vFirstNames, 
					vLastName,
					vUserName,
					vActive);
                    
			INSERT INTO prism_settings(sCode, sDescription)
            VALUES(vOperatorCode, CONCAT(vFirstNames, ' ', vLastName, ' Settings'));
            
			UPDATE operators O
			SET ifkSettingsID = (select ipkSettingsID from prism_settings as PS where PS.sCode = vOperatorCode)
			WHERE O.sOperatorCode = vOperatorCode;   
                    
		END;
	END IF;
    
END$$

DELIMITER ;

