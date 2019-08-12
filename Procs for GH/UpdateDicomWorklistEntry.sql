USE `promed`;
DROP procedure IF EXISTS `UpdateDicomWorklistEntry`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDicomWorklistEntry`(IN vAccountCode varchar(10),IN vAccessionID INTEGER)
BEGIN
	DECLARE vAccountID INT;
    DECLARE vModalityID INT;
    DECLARE vExamID INT;
    DECLARE vAccountExamID INT;
    	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[UDWE]:',msg),1,128);   	
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
    SELECT ipkAccountID into vAccountID FROM accounts A WHERE A.sAccountCode = vAccountCode;

	IF EXISTS (SELECT ipkDicomWorklistID FROM dicom_worklist DWL WHERE ifkAccountID = vAccountID and ifkAccessionID = vAccessionID ) THEN
		BEGIN
			SELECT AE.ipkAccountExamID, AE.ifkModalityID, AE.ifkExamID 
				INTO vAccountExamID, vModalityID, vExamID 
                FROM account_exams AE 
                WHERE ae.ifkAccessionID = vAccessionID and  AE.ifkAccountID = vAccountID 
					group by AE.ipkAccountExamID, AE.ifkModalityID, AE.ifkExamID
                    HAVING AE.ipkAccountExamID = MIN(AE.ipkAccountExamID) limit 1;

			UPDATE dicom_worklist DWL 
			INNER JOIN accounts A
				ON DWL.ifkAccountID = A.ipkAccountID
			INNER JOIN wards W
				ON W.ipkWardID = A.ifkWardID
			LEFT JOIN referring_doctors RD
				ON A.ifkPrimaryReferringDoctorID = RD.ipkReferringDoctorID
				SET	DWL.dStudyDate = replace(cast(cast(A.dExamDate as date) as char(10)), '-', ''),
					DWL.ifkModalityID = vModalityID,
					DWL.ifkReferringDoctorID = RD.ipkReferringDoctorID,
					DWL.sHospitalNumber = A.sHospitalNumber,
					DWL.ifkWardID = W.ipkWardID,
					DWL.sDoctorGroup = CASE A.bHospitalDoctor
						WHEN 1
							THEN 'HOSPITAL'
						ELSE
							CONCAT(RD.sSurname, ' ', RD.sInitials, ' ', RD.sTitle)
					END,
					DWL.sDoctorMedia = A.sDoctorMedia,
					DWL.bComplete = 0,
					DWL.bDeleted = 0,
					DWL.iHandled = 0,
					DWL.ifkExamID = vExamID
			WHERE A.ipkAccountID = vAccountID and DWL.ifkAccessionID = vAccessionID;
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

