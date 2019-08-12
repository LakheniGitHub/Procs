USE `promed`;
DROP procedure IF EXISTS `CaptureBooking`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CaptureBooking`(IN vBookingCode varchar(15),
  IN vStartTime timestamp,
  IN vFinishTime timestamp,
  IN vType varchar(25),
  IN vOption varchar(25),
  IN vMessage longtext,
  IN vState int(11),
  IN vColor int(11),
  IN vLocation varchar(45),
  IN vCaption varchar(200), 
  IN vSiteID int(11),
  IN vRoomCode varchar(10),
  IN vBooking tinyint(4),
  IN vOperator varchar(4))
BEGIN
	declare vNewBookingCode varchar(15);
    declare vNewBookingID bigint;
    /*declare vBranchID bigint;*/
    declare vRoomID bigint;
    declare vIsBooking tinyint(4);
    declare vBlock tinyint(4);
    declare vOperatorID bigint;
    declare vFlowStatus bigint;
    
    /*SELECT ipkBranchID into vBranchID FROM branches WHERE sBranchCode = vBranchCode;*/
    SELECT ipkRoomID into vRoomID FROM rooms WHERE sRoomCode = vRoomCode;
    SELECT ipkOperatorID into vOperatorID FROM operators WHERE sOperatorCode = vOperator; 
    
	DROP TEMPORARY TABLE IF EXISTS tmpresult; 
    CREATE TEMPORARY TABLE tmpresult ( 
        sBookingCode varchar(15),
        iBookingID BIGINT
	) ENGINE=MEMORY;  	
    
	IF (vBookingCode = '') THEN
		SET vBookingCode = null;
	END IF;  
    
	IF (vType = '') THEN
		SET vType = null;
	END IF;  
    
	IF (vOption = '') THEN
		SET vOption = null;
	END IF;  
    
    SET vIsBooking = 1;
    SET vBlock = 0;
    IF (vBooking = False) THEN
		SET vIsBooking = 0;
        SET vBlock = 1;
	END IF;
    
    /* Set flow status to scheduled*/
    SET vFlowStatus = 2;
    
    IF (vBookingCode IS NULL) THEN
		BEGIN
			IF (vIsBooking = 1) THEN
					SELECT CONCAT(sPrefix, LPAD(CAST((COALESCE(iCounter, 0) + 1) AS CHAR), 6, '0')) AS sBookingCode
					INTO vNewBookingCode
					FROM booking_prefix
					WHERE bEnabled = 1
                    AND bBlock = 0;
				ELSE
					SELECT CONCAT(sPrefix, LPAD(CAST((COALESCE(iCounter, 0) + 1) AS CHAR), 6, '0')) AS sBookingCode
					INTO vNewBookingCode
					FROM booking_prefix
					WHERE bEnabled = 1
                    AND bBlock = 1;
            END IF;
            
			INSERT INTO bookings(sBookingCode,
								dStartTime,
								dFinishTime,
								sType,
								sOption,
								sMessage,
								iState,
								iColor,
								sLocation,
								sCaption,
                                ifkSiteID,
                                /*ifkBranchID,*/
                                ifkRoomID,
                                bBlock,
                                ifkCreaterOperatorID,
                                ifkFlowStatusID)
			VALUES(vNewBookingCode,
					vStartTime,
					vFinishTime,
					vType,
					vOption,
					vMessage, 
					vState,
					vColor,
					vLocation,
					vCaption,
                    vSiteID,
                    /*vBranchID,*/
                    vRoomID,
                    vBlock,
                    vOperatorID,
                    vFlowStatus);
            
			IF (vIsBooking = 1) THEN
					UPDATE booking_prefix
					SET iCounter = IFNULL(iCounter, 0) + 1
					WHERE bEnabled = 1
                    AND bBlock = 0;
				ELSE
					UPDATE booking_prefix
					SET iCounter = IFNULL(iCounter, 0) + 1
					WHERE bEnabled = 1
                    AND bBlock = 1;
            END IF;
            
		SET vNewBookingID = (SELECT @@IDENTITY);
        
        INSERT INTO tmpresult(sBookingCode, iBookingID) values (vNewBookingCode, vNewBookingID);
		END;
	ELSE
		BEGIN
			UPDATE bookings
				SET dStartTime = vStartTime,
					dFinishTime = vFinishTime,
					sType = vType,
					sOption = vOption,
					sMessage = vMessage,
					iState = vState,
					iColor = vColor,
					sLocation = vLocation,
					sCaption = vCaption,
                    ifkSiteID = vSiteID,
                    /*ifkBranchID = vBranchID,*/
                    ifkRoomID = vRoomID
			WHERE sBookingCode = vBookingCode; 
            
            INSERT INTO tmpresult(sBookingCode, iBookingID) values (vBookingCode, (select ipkBookingID from bookings where sBookingCode = vBookingCode));
		END;
	END IF;
    
	
    SELECT * from tmpresult;
	DROP TEMPORARY TABLE IF EXISTS tmpresult;
END$$

DELIMITER ;

