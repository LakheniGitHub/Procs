USE `promed`;
DROP procedure IF EXISTS `GetMinAccountDetail`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetMinAccountDetail`(IN vAccountCode VARCHAR(10))
BEGIN 
    declare vAccID bigint;
	declare vExamCount integer;
	declare vReceipted integer;
	
	select ipkAccountID into vAccID from accounts where sAccountCode = vAccountCode;
	select count(*) into vExamCount from account_exams where ifkAccountID = vAccID;
	select count(*) into vReceipted from receipts where ifkAccountID = vAccID;
	
	SELECT 					vExamCount as iExamCount,
							vReceipted as iReceiptCount,
							A.iLineCount,
							A.ifkPatientID, 
							A.ifkMemberID,
							MA.sCode AS sMedicalAidCode,
							MA.sEmail as sMedicalEmail,
							MAP.sGlobalMedicalAidCode ,
							A.sAccountCode,
							A.dDateEntered, 
							A.bWCA,
                            A.bMVA, 
							A.bBurnCD,
							A.bWaiting,
							A.bHospitalPatient ,
							A.sHospitalNumber,
                            A.bNoAuthRequired,
							A.sAuthorization,
							A.bAfterHours,
							A.bHold,
							A.bEMail,
							A.iCDCopies,
                            A.bVATInvoice,
                            A.bPatientRequestsCD ,
							B.sBranchCode,
                            FS.sFeeStatus,
                            A.ifkFeeingTypeID ,
                            A.ipkAccountID,
                            A.bPatientPay,
                            A.bReportOnly,
                            A.ifkFeeMedicalAidID,
							A.ifkFeeMedicalAidPlanID,
							M.ifkMedicalAidID,
							a.ifkSiteID,
							S.sSiteFolder,
							s.sSiteName,
							A.bDebtorAccount,
							s.sFinalNoticeReport,
							s.sHandOverReport,
							s.sStatementReport,
							s.sReceiptReport,
							s.sJobcardReport,
							s.sPatientInfoReport,
							s.sLabelReport,
							s.sStatementExclReport,
							s.sQuoteReport,
							q.ipkQuoteID
					FROM sites S,accounts A
					LEFT JOIN members M
						ON A.ifkMemberID = M.ipkMemberID
					LEFT JOIN medical_aid MA
						ON MA.ipkMedicalAidID = M.ifkMedicalAidID
					LEFT JOIN medical_aid_plan MAP
						ON MAP.ipkMedicalAidPlanID = M.ifkMedicalAidPlanID
					LEFT JOIN branches B
						ON B.ipkBranchID = A.ifkBranchID
					LEFT JOIN feeing_statuses FS
						ON FS.ipkFeeingStatusID = A.ifkFeeingStatusID
                    left join quote q
                        on q.ifkAccountID = a.ipkAccountID					
					WHERE A.ipkAccountID = vAccID and S.ipkSiteID = A.ifkSiteID;
	
END$$

DELIMITER ;

