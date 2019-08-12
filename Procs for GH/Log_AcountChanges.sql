USE `promed`;
DROP procedure IF EXISTS `Log_AcountChanges`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Log_AcountChanges`(IN iAccountID bigint)
BEGIN
/**/ 
declare vMemID bigint;
declare vUsername varchar(20);
declare v_H_sAddressLine1 varchar(50);
declare v_H_sAddressLine2 varchar(50);
declare v_H_sAddressLine3 varchar(50);
declare v_H_sAddressLine4 varchar(50);
declare v_H_sPostal varchar(10);
declare v_H_sTel varchar(15);
declare v_H_sExt varchar(15);

declare v_W_sAddressLine1 varchar(50);
declare v_W_sAddressLine2 varchar(50);
declare v_W_sAddressLine3 varchar(50);
declare v_W_sAddressLine4 varchar(50);
declare v_W_sPostal varchar(10);
declare v_W_sTel varchar(15);
declare v_W_sExt varchar(15);

declare v_P_sAddressLine1 varchar(50);
declare v_P_sAddressLine2 varchar(50);
declare v_P_sAddressLine3 varchar(50);
declare v_P_sAddressLine4 varchar(50);
declare v_P_sPostal varchar(10);
declare v_P_sTel varchar(15);
declare v_P_sExt varchar(15);

declare v_R_sAddressLine1 varchar(50);
declare v_R_sAddressLine2 varchar(50);
declare v_R_sAddressLine3 varchar(50);
declare v_R_sAddressLine4 varchar(50);
declare v_R_sPostal varchar(10);
declare v_R_sTel varchar(15);
declare v_R_sExt varchar(15);

	/* On success return 1 , else 0 */
    	    	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[LAC]:',msg),1,128);   	
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
   
select ifkMemberID,sUserName into vMemID,vUsername from accounts where ipkAccountID = iAccountID;

INSERT INTO promed_logs.account_change_log
(ipkAccountChangeLogID,
A_ifkAccountID,
A_ifkPatientID,
A_ifkPremergePatientID,
A_ifkClaimStatusID,
A_ifkCDStatusID,
A_ifkEligibilityStatusID,
A_ifkTeleradStatusID,
A_ifkAccountFlowStatusID,
A_ifkFeeingStatusID,
A_ifkPrimaryReferringDoctorID,
A_ifkSecondaryReferringDoctorID,
A_ifkFeeingTypeID,
A_ifkWardID,
A_ifkSiteID,
A_ifkCancelledByOperatorsID,
A_ifkLockedByOperatorsID,
A_ifkICD10StatusID,
A_ifkMergeOperatorID,
A_ifkAccountFlowGroupID,
A_ifkFrozenByOperatorID,
A_ifkXRayTypeID,
A_ifkILOReportTypeID,
A_ifkMethodOfPaymentID,
A_ifkBranchID,
A_sAccountCode,
A_sUserName,
A_sBaddebptOverride,
A_ifkPatientConditionID,
A_sOperator,
A_sAuthorization,
A_sFeedBy,
A_sDepartment,
A_sPrimaryCustomDoctor,
A_sSecondaryCustomDoctor,
A_sHospitalNumber,
A_sPromedInitials,
A_sDoctorMedia,
A_sComment1,
A_sComment2,
A_sFilename,
A_sOUID,
A_sMobileID,
A_sCompanyName,
A_sOrderNumber,
A_sOHNumber,
A_sOccupationHistory,
A_iFactor,
A_fExcessAmount,
A_dDateEntered,
A_dDateExported,
A_dExamDate,
A_dTransactionDate,
A_dXRayDate,
A_iAccountDateSequence,
A_bActive,
A_bDeleted,
A_bWCA,
A_bMVA,
A_bAfterHours,
A_bCompleted,
A_bVATInvoice,
A_bHospitalPatient,
A_bExported,
A_bHold,
A_bPregnant,
A_bUrgent,
A_bWaiting,
A_bDeliver,
A_bPaying,
A_bSynched,
A_bBurnCD,
A_bEMail,
A_bLANExport,
A_bHospitalDoctor,
A_bArchive,
A_bDespatch,
A_bPreviousImages,
A_bDespatchFlow,
A_bInteresting,
A_bPatientRequestsCD,
A_bBreastFeeding,
A_bVirtualClaim,
A_bDespatched,
A_bSmoker,
A_iStructError,
A_iOrderError,
A_iCDCopies,
A_iSmokeYears,
A_bRestrictImages,
A_ifkMemberID,
A_fBalance,
A_fVatTotal,
A_fReceiptTotal,
A_fPaidTotal,
A_iLineCount,
A_ifkMedicalAidPlanID,
A_ifkMedicalAidID,
A_sMedicalAidReferenceNumber,
A_tTotalScreenTime,
A_fTotalRadiationDosage,
A_ifkLegalEntityID,
A_bNoAuthRequired,
A_bPatientPay,
A_bReportOnly,
A_fFeeSpecialAmount,
A_fFeeFactor,
A_sNote,
A_ifkFeeMedicalAidID,
A_ifkFeeMedicalAidPlanID,
P_ifkMemberID,
P_ifkOriginalPatientID,
P_ifkPatientSiteID,
P_sTitle,
P_sInitials,
P_sName,
P_sSurname,
P_sIDNumber,
P_dDateOfBirth,
P_dDateEntered,
P_iPDependantNo,
P_bAppointment,
P_sUID,
P_bActive,
P_bNonSAID,
P_bSmoking,
P_bVIP,
P_bConsent,
P_bParentConsent,
P_sAllergies,
P_sOccupation,
P_blPatientInfo,
P_sCompanyName,
P_iWeight,
P_bValves,
P_bAsthma,
P_bPregnant,
P_bPacemaker,
P_bMetalInHead,
P_bClips,
P_sCellphone,
P_sSex,
P_sLanguage,
P_sEmail,
P_sEmployeeNumber,
P_sFax,
P_sComsPreference,
P_ifkRelationID,
P_sHomeTel,
P_sWorkTel,
P_sForceNumber,
M_ifkMedicalAidID,
M_ifkMedicalAidPlanID,
M_dDateEntered,
M_dMemberDateOfBirth,
M_sMedicalAidClaim,
M_iDependants,
M_sVatNo,
M_sTitle,
M_sInitials,
M_sName,
M_sNextOfKinName,
M_sNextOfKinRelation,
M_bNonSAID,
M_bConsent,
M_sMedicalAidReference,
M_sIDNumber,
M_sCellphone,
M_sNextOfKinTel,
M_sEmployer,
M_sOccupation,
M_sWorkDepartment,
M_sFax,
M_sEmail,
M_sEmployeeNumber,
M_sCompanyNumber,
M_sRelation,
M_sSurname,
M_sHomeTel,
M_sWorkTel) SELECT 0,A.ipkAccountID,
    A.ifkPatientID,
    A.ifkPremergePatientID,
    A.ifkClaimStatusID,
    A.ifkCDStatusID,
    A.ifkEligibilityStatusID,
    A.ifkTeleradStatusID,
    A.ifkAccountFlowStatusID,
    A.ifkFeeingStatusID,
    A.ifkPrimaryReferringDoctorID,
    A.ifkSecondaryReferringDoctorID,
    A.ifkFeeingTypeID,
    A.ifkWardID,
    A.ifkSiteID,
    A.ifkCancelledByOperatorsID,
    A.ifkLockedByOperatorsID,
    A.ifkICD10StatusID,
    A.ifkMergeOperatorID,
    A.ifkAccountFlowGroupID,
    A.ifkFrozenByOperatorID,
    A.ifkXRayTypeID,
    A.ifkILOReportTypeID,
    A.ifkMethodOfPaymentID,
    A.ifkBranchID,
    A.sAccountCode,
    A.sUserName,
    A.sBaddebptOverride,
    A.ifkPatientConditionID,
    A.sOperator,
    A.sAuthorization,
    A.sFeedBy,
    A.sDepartment,
    A.sPrimaryCustomDoctor,
    A.sSecondaryCustomDoctor,
    A.sHospitalNumber,
    A.sPromedInitials,
    A.sDoctorMedia,
    A.sComment1,
    A.sComment2,
    A.sFilename,
    A.sOUID,
    A.sMobileID,
    A.sCompanyName,
    A.sOrderNumber,
    A.sOHNumber,
    A.sOccupationHistory,
    A.iFactor,
    A.fExcessAmount,
    A.dDateEntered,
    A.dDateExported,
    A.dExamDate,
    A.dTransactionDate,
    A.dXRayDate,
    A.iAccountDateSequence,
    A.bActive,
    A.bDeleted,
    A.bWCA,
    A.bMVA,
    A.bAfterHours,
    A.bCompleted,
    A.bVATInvoice,
    A.bHospitalPatient,
    A.bExported,
    A.bHold,
    A.bPregnant,
    A.bUrgent,
    A.bWaiting,
    A.bDeliver,
    A.bPaying,
    A.bSynched,
    A.bBurnCD,
    A.bEMail,
    A.bLANExport,
    A.bHospitalDoctor,
    A.bArchive,
    A.bDespatch,
    A.bPreviousImages,
    A.bDespatchFlow,
    A.bInteresting,
    A.bPatientRequestsCD,
    A.bBreastFeeding,
    A.bVirtualClaim,
    A.bDespatched,
    A.bSmoker,
    A.iStructError,
    A.iOrderError,
    A.iCDCopies,
    A.iSmokeYears,
    A.bRestrictImages,
    A.ifkMemberID,
    A.fBalance,
    A.fVatTotal,
    A.fReceiptTotal,
    A.fPaidTotal,
    A.iLineCount,
    A.ifkMedicalAidPlanID,
    A.ifkMedicalAidID,
    A.sMedicalAidReferenceNumber,
    A.tTotalScreenTime,
    A.fTotalRadiationDosage,
    A.ifkLegalEntityID,
    A.bNoAuthRequired,
    A.bPatientPay,
    A.bReportOnly,
    A.fFeeSpecialAmount,
    A.fFeeFactor,
    A.sNote,
    A.ifkFeeMedicalAidID,
    A.ifkFeeMedicalAidPlanID,
	P.ifkMemberID,
    P.ifkOriginalPatientID,
    P.ifkSiteID,
    P.sTitle,
    P.sInitials,
    P.sName,
    P.sSurname,
    P.sIDNumber,
    P.dDateOfBirth,
    P.dDateEntered,
    P.iPDependantNo,
    P.bAppointment,
    P.sUID,
    P.bActive,
    P.bNonSAID,
    P.bSmoking,
    P.bVIP,
    P.bConsent,
    P.bParentConsent,
    P.sAllergies,
    P.sOccupation,
    P.blPatientInfo,
    P.sCompanyName,
    P.iWeight,
    P.bValves,
    P.bAsthma,
    P.bPregnant,
    P.bPacemaker,
    P.bMetalInHead,
    P.bClips,
    P.sCellphone,
    P.sSex,
    P.sLanguage,
    P.sEmail,
    P.sEmployeeNumber,
    P.sFax,
    P.sComsPreference,
    P.ifkRelationID,
    P.sHomeTel,
    P.sWorkTel,
    P.sForceNumber,
	M.ifkMedicalAidID,
    M.ifkMedicalAidPlanID,
    M.dDateEntered,
    M.dMemberDateOfBirth,
    M.sMedicalAidClaim,
    M.iDependants,
    M.sVatNo,
    M.sTitle,
    M.sInitials,
    M.sName,
    M.sNextOfKinName,
    M.sNextOfKinRelation,
    M.bNonSAID,
    M.bConsent,
    M.sMedicalAidReference,
    M.sIDNumber,
    M.sCellphone,
    M.sNextOfKinTel,
    M.sEmployer,
    M.sOccupation,
    M.sWorkDepartment,
    M.sFax,
    M.sEmail,
    M.sEmployeeNumber,
    M.sCompanyNumber,
    M.sRelation,
    M.sSurname,
    M.sHomeTel,
    M.sWorkTel
FROM accounts A,patients P, members M
where A.ipkaccountid = iAccountID and P.ipkpatientid = a.ifkpatientid and M.ipkmemberid = A.ifkmemberid;

 
SELECT sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode,sTel,sExtension 
		into v_H_sAddressLine1,v_H_sAddressLine2,v_H_sAddressLine3,v_H_sAddressLine4,v_H_sPostal,v_H_sTel,v_H_sExt  
FROM member_addresses ma,member_address_type mat
where ma.ifkMEmberAddressTypeID = mat.ipkMemberAddressTypeID
and ma.ifkMemberID = vMemID
and mat.sCode = 'H';

SELECT sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode,sTel,sExtension 
		into v_P_sAddressLine1,v_P_sAddressLine2,v_P_sAddressLine3,v_P_sAddressLine4,v_P_sPostal,v_P_sTel,v_P_sExt  
FROM member_addresses ma,member_address_type mat
where ma.ifkMEmberAddressTypeID = mat.ipkMemberAddressTypeID
and ma.ifkMemberID = vMemID
and mat.sCode = 'P';

SELECT sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode,sTel,sExtension 
		into v_R_sAddressLine1,v_R_sAddressLine2,v_R_sAddressLine3,v_R_sAddressLine4,v_R_sPostal,v_R_sTel,v_R_sExt  
FROM member_addresses ma,member_address_type mat
where ma.ifkMEmberAddressTypeID = mat.ipkMemberAddressTypeID
and ma.ifkMemberID = vMemID
and mat.sCode = 'R';

SELECT sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode,sTel,sExtension 
		into v_W_sAddressLine1,v_W_sAddressLine2,v_W_sAddressLine3,v_W_sAddressLine4,v_W_sPostal,v_W_sTel,v_W_sExt  
FROM member_addresses ma,member_address_type mat
where ma.ifkMEmberAddressTypeID = mat.ipkMemberAddressTypeID
and ma.ifkMemberID = vMemID
and mat.sCode = 'E';

INSERT INTO promed_logs.account_member_address_log (ipkAccMemberAddLogID,dLogDate,MA_H_sAddressLine1,MA_H_sAddressLine2,MA_H_sAddressLine3,MA_H_sAddressLine4,MA_H_sPostalCode,
											MA_H_sTel,MA_H_sExt,MA_P_sAddressLine1,MA_P_sAddressLine2,MA_P_sAddressLine3,MA_P_sAddressLine4,MA_P_sPostalCode,MA_P_sTel,
										MA_P_sExt,MA_W_sAddressLine1,MA_W_sAddressLine2,MA_W_sAddressLine3,MA_W_sAddressLine4,MA_W_sPostalCode,MA_W_sTel,MA_W_sExt,MA_R_sAddressLine1,
										MA_R_sAddressLine2,MA_R_sAddressLine3,MA_R_sAddressLine4,MA_R_sPostalCode,MA_R_sTel,MA_R_sExt,A_ifkAccountID,A_ifkMemberID,A_sUserName)
										VALUES
							(0,CURRENT_TIMESTAMP,v_H_sAddressLine1,v_H_sAddressLine2,v_H_sAddressLine3,v_H_sAddressLine4,
							v_H_sPostal,v_H_sTel,v_H_sExt,v_P_sAddressLine1,v_P_sAddressLine2,v_P_sAddressLine3,v_P_sAddressLine4,v_P_sPostal,
							v_P_sTel,v_P_sExt,v_W_sAddressLine1,v_W_sAddressLine2,v_W_sAddressLine3,v_W_sAddressLine4,v_W_sPostal,v_W_sTel,v_W_sExt,
							v_R_sAddressLine1,v_R_sAddressLine2,v_R_sAddressLine3,v_R_sAddressLine4,v_R_sPostal,v_R_sTel,v_R_sExt,iAccountID,vMemID,vUsername);

	if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
END$$

DELIMITER ;

