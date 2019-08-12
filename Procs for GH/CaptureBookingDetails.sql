USE `promed`;
DROP procedure IF EXISTS `CaptureBookingDetails`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CaptureBookingDetails`(IN vBookingID int(11),
  IN vDetailsID int(11),
  IN vPatientTitle varchar(5),
  IN vPatientInitials varchar(5),
  IN vPatientFirstname varchar(15),
  IN vPatientSurname varchar(50),
  IN vPatientIDNumber varchar(13),
  IN vPatientBirthDate date,
  IN vPatientRelation varchar(10),
  IN vPatientDependant int(11),
  IN vPatientMobility varchar(2),
  IN vHospitalPatient tinyint,
  IN vHospitalNumber varchar(15),
  IN vPatientCellphone varchar(15),
  IN vPatientHomeTel varchar(15),
  IN vPatientWorkTel varchar(15),
  IN vPatientFax varchar(15),
  IN vPatientEmail varchar(255),
  IN vConfirmation tinyint,
  IN vReminder tinyint,
  IN vMemberTitle varchar(5),
  IN vMemberInitials varchar(5),
  IN vMemberFirstname varchar(15),
  IN vMemberSurname varchar(50),
  IN vMedicalAid varchar(6),
  IN vMedicalAidPlan varchar(9),
  IN vMedicalAidReferenceNumber varchar(45),
  IN vReferringDoctor varchar(5),
  IN vNoAuthRequired tinyint,
  IN vOperator varchar(4),
  IN vAuthNumber varchar(50),
  IN vComment text,
  IN vPatientID int(11),
  IN vMemberID int(11),
  IN vSMSConfirmation tinyint,
  IN vSMSReminder tinyint,
  IN vEmailConfirmation tinyint,
  IN vEmailReminder tinyint)
BEGIN
	declare vMedaidID bigint;
    declare vMedaidPlanID bigint;
	declare vRefdocID bigint;
	declare vPatCondID bigint;
    declare vPatRelationID bigint;
    declare vOperatorID bigint;
    declare vNewDetailsID bigint;
    declare vAuthOperatorID bigint;
    declare vBookingCode varchar(15);
    declare vUserName varchar(50);

	SELECT ipkPatientConditionID into vPatCondID FROM patient_conditions WHERE sCode = vPatientMobility;
	SELECT max(ipkReferringDoctorID) into vRefdocID FROM referring_doctors WHERE sCode = vReferringDoctor;
	SELECT ipkRelationID into vPatRelationID FROM relations WHERE sCode = vPatientRelation;
	SELECT ipkMedicalAidID into vMedaidID FROM medical_aid WHERE sCode = vMedicalAid;
	SELECT ipkMedicalAidPlanID into vMedaidPlanID FROM medical_aid_plan WHERE sGlobalMedicalAidCode = vMedicalAidPlan;
    SELECT ipkOperatorID, sUserName into vOperatorID, vUserName FROM operators WHERE sOperatorCode = vOperator; 
    SELECT sBookingCode into vBookingCode FROM bookings WHERE ipkBookingID = vBookingID;
    
 	IF (vDetailsID = 0) THEN
		SET vDetailsID = null;
	END IF;  
    
 	IF (vPatientID = 0) THEN
		SET vPatientID = null;
	END IF;  
    
 	IF (vMemberID = 0) THEN
		SET vMemberID = null;
	END IF;  
    
    set vAuthOperatorID = null;
    IF (vAuthNumber <> '') THEN
	    SET vAuthOperatorID = vOperatorID;
	END IF;
    
    if (vHospitalPatient = -1) then
		set vHospitalPatient = 1; 
	end if;
    
    if (vConfirmation = -1) then
		set vConfirmation = 1; 
	end if;
    
    if (vReminder = -1) then
		set vReminder = 1; 
	end if;
    
    if (vNoAuthRequired = -1) then
		set vNoAuthRequired = 1; 
	end if;

	IF (vDetailsID is null) THEN  
		BEGIN
            SELECT MAX(ipkDetailsID) + 1 into vNewDetailsID FROM booking_details; 
            
			INSERT INTO booking_details(sPatientTitle,
									  sPatientInitials,
									  sPatientFirstname,
									  sPatientSurname,
									  sPatientIDNumber,
									  dPatientBirthDate,
                                      iDependantNo,
									  ifkPatientRelationID,
									  ifkPatientMobilityID,
									  bHospitalPatient,
									  sHospitalNumber,
									  sPatientCellphone,
									  sPatientHomeTel,
									  sPatientWorkTel,
									  sPatientFax,
									  sPatientEmail,
									  bConfirmation,
									  bReminder,
									  sMemberTitle,
									  sMemberInitials,
									  sMemberFirstname,
									  sMemberSurname,
									  ifkMedicalAidID,
									  ifkMedicalAidPlanID,
									  sMedicalAidReferenceNumber,
									  ifkReferringDoctorID,
									  bNoAuthRequired,
									  ifkAuthOperatorID,
									  sAuthNumber,
                                      tComment,
                                      ifkPatientID,
                                      ifkMemberID,
									  bSMSConfirmation,
									  bSMSReminder,
									  bEmailConfirmation,
									  bEmailReminder)
			VALUES(vPatientTitle,
				   vPatientInitials,
				   vPatientFirstname,
				   vPatientSurname,
				   vPatientIDNumber,
				   vPatientBirthDate,
                   vPatientDependant,
				   vPatRelationID, 
				   vPatCondID,
				   vHospitalPatient,
				   vHospitalNumber,
				   vPatientCellphone,
				   vPatientHomeTel,
				   vPatientWorkTel,
				   vPatientFax,
				   vPatientEmail,
				   vConfirmation,
				   vReminder,
				   vMemberTitle,
				   vMemberInitials,
				   vMemberFirstname,
				   vMemberSurname,
				   vMedaidID,
				   vMedaidPlanID,
				   vMedicalAidReferenceNumber,
				   vRefdocID,
				   vNoAuthRequired,
				   vAuthOperatorID,
				   vAuthNumber,
                   vComment,
                   vPatientID,
                   vMemberID,
                   vSMSConfirmation,
				   vSMSReminder,
				   vEmailConfirmation,
				   vEmailReminder);
                   
			UPDATE bookings
			SET ifkDetailsID = vNewDetailsID
			WHERE ipkBookingID = vBookingID;
		END;
	ELSE
		BEGIN
			UPDATE booking_details
			SET sPatientTitle = vPatientTitle,
				sPatientInitials = vPatientInitials,
				sPatientFirstname = vPatientFirstname,
				sPatientSurname = vPatientSurname, 
				sPatientIDNumber = vPatientIDNumber,
				dPatientBirthDate = vPatientBirthDate,
                iDependantNo = vPatientDependant,
				ifkPatientRelationID = vPatRelationID,
				ifkPatientMobilityID = vPatCondID,
				bHospitalPatient = vHospitalPatient,
				sHospitalNumber = vHospitalNumber,
				sPatientCellphone = vPatientCellphone,
				sPatientHomeTel = vPatientHomeTel,
				sPatientWorkTel = vPatientWorkTel,
				sPatientFax = vPatientFax,
				sPatientEmail = vPatientEmail,
				bConfirmation = vConfirmation,
				bReminder = vReminder,
				sMemberTitle = vMemberTitle,
				sMemberInitials = vMemberInitials,
				sMemberFirstname = vMemberFirstname,
				sMemberSurname = vMemberSurname,
				ifkMedicalAidID = vMedaidID,
				ifkMedicalAidPlanID = vMedaidPlanID,
				sMedicalAidReferenceNumber = vMedicalAidReferenceNumber,
				ifkReferringDoctorID = vRefdocID,
				bNoAuthRequired = vNoAuthRequired,
				/*sAuthNumber = vAuthNumber,*/
                tComment = vComment,
				bSMSConfirmation =  vSMSConfirmation,
				bSMSReminder = vSMSReminder,
				bEmailConfirmation = vEmailConfirmation,
				bEmailReminder = vEmailReminder
			WHERE ipkDetailsID = vDetailsID;
            
            /*IF (vAuthNumber <> '') THEN*/
            IF (vAuthNumber <> (select sAuthNumber from booking_details where ipkDetailsID = vDetailsID)) THEN
				UPDATE booking_details
				SET ifkAuthOperatorID = vAuthOperatorID,
                sAuthNumber = vAuthNumber
				WHERE ipkDetailsID = vDetailsID;
                /*AND IFNULL(ifkAuthOperatorID, '') = '';*/
            end if;
		END;
	END IF;
    
    CALL Log_BookingChanges(vBookingID, vDetailsID); 
    
	CALL EligSubmitBookingPV(vBookingCode, vUserName);
	CALL EligSubmitBookingBFC(vBookingCode, vUserName);
END$$

DELIMITER ;

