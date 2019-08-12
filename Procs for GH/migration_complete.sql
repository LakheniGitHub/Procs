USE `promed`;
DROP procedure IF EXISTS `migration_complete`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `migration_complete`()
BEGIN
/*Runs thru migration tables and creates acounts for all those that dont have accounts yet
IF account code exist it  is ignored, update doc image account if for account also if there is a entry for the report in it
*/
/*Such a painfull way todo this, but here we go */

	declare vAccountID bigint; 
	/*DECLARE ACC_CODE varchar(10) ;*/
	DECLARE vACC_CODE varchar(10) ;
	DECLARE vP_UID varchar(64) ;
	DECLARE vP_SURNAME varchar(45) ;
	DECLARE vP_NAME varchar(45) ;
	DECLARE vP_ID varchar(45) ;
	DECLARE vP_SITE_ID varchar(3) ;
	DECLARE vP_INITIALS varchar(5) ;
	DECLARE vP_TITLE varchar(5) ;
	DECLARE vP_DOB datetime ;
	DECLARE vP_DEP_NO int(11) ;
	DECLARE vP_NON_SA_ID int(11) ;
	DECLARE vP_VIP int(11) ;
	DECLARE vP_SMOKING int(11) ;
	DECLARE vP_CONSENT int(11) ;
	DECLARE vP_PARENTCONSENT int(11) ;
	DECLARE vP_DATE_ENTERED datetime ;
	DECLARE vP_GENDER char(1) ;
	DECLARE vP_CELLPHONE varchar(15) ;
	DECLARE vP_LANGUAGE char(1) ;
	DECLARE vP_ALLERGIES varchar(30) ;
	DECLARE vP_WEIGHT int(11) ;
	DECLARE vP_VALVES int(11) ;
	DECLARE vP_ASHMA int(11) ;
	DECLARE vP_PREGNANT int(11) ;
	DECLARE vP_PACEMAKER int(11) ;
	DECLARE vP_METAL_IN_HEAD int(11) ;
	DECLARE vP_CLIPS int(11) ;
	DECLARE vP_OCCUPATION varchar(45) ;
	DECLARE vP_EMAIL varchar(255) ;
	DECLARE vP_FORCENUMBER varchar(15) ;
	DECLARE vP_COMPANYNUMBER varchar(15) ;
	DECLARE vP_PATIENTINFO text;
	DECLARE vP_FAX varchar(15) ;
	DECLARE vP_COMMS_PREF varchar(1) ;
	DECLARE vP_COMPANY_NAME varchar(50) ;
	DECLARE vM_MED_AID varchar(6) ;
	DECLARE vM_MED_AID_REF varchar(45) ;
	DECLARE vM_MED_AID_CLAIM varchar(10) ;
	DECLARE vM_TITLE varchar(5) ;
	DECLARE vM_INITIALS varchar(5) ;
	DECLARE vM_NAME varchar(45);
	DECLARE vM_ID varchar(15) ;
	DECLARE vM_CELLPHONE varchar(15) ;
	DECLARE vM_RELATION varchar(5) ;
	DECLARE vM_NOK_NAME varchar(45) ;
	DECLARE vM_NOK_RELATION varchar(5) ;
	DECLARE vM_NOK_TEL varchar(15) ;
	DECLARE vM_EMPLOYER varchar(45) ;
	DECLARE vM_OCCUPATION varchar(45) ;
	DECLARE vM_WORK_DEPT varchar(45) ;
	DECLARE vM_NUM_DEPENDANTS int(11) ;
	DECLARE vM_DATE_ENTERED datetime ;
	DECLARE vM_FAX varchar(15) ;
	DECLARE vM_DOB datetime ;
	DECLARE vM_EMAIL varchar(255) ;
	DECLARE vM_FORCE_NUMBER varchar(15) ;
	DECLARE vM_COMPANY_NUMBER varchar(15) ;
	DECLARE vM_VAT_NUMBER varchar(10) ;
	DECLARE vM_NON_SA_ID int(11) ;
	DECLARE vM_MED_AID_PLAN varchar(10) ;
	DECLARE vM_CONSENT int(11) ;
	DECLARE vWCA_EMPLOYER varchar(45) ;
	DECLARE vWCA_EMPOYER_TEL varchar(15) ;
	DECLARE vWCA_OCCUPATION varchar(45) ;
	DECLARE vWCA_DEPARTMENT varchar(45) ;
	DECLARE vWCA_COMPANY_NUMBER varchar(45) ;
	DECLARE vWCA_DOI datetime ;
	DECLARE vWCA_WCA_CLAIM_NUMBER varchar(45) ;
	DECLARE vWCA_CLAIM_TYPE varchar(1) ;
	DECLARE vWCA_DATE_ENTERED datetime ;
	DECLARE vWCA_CLAIM_REF_NUM varchar(45) ;
	DECLARE vV_EXAM_ADDED int(11) ;
	DECLARE vV_REPORT_STATUS int(11) ;
	DECLARE vV_JOBCARD_STATUS int(11) ;
	DECLARE vV_RADIOLOGIST varchar(5) ;
	DECLARE vV_RADIOGRAPHER varchar(5) ;
	DECLARE vV_JUNIOR_RADIOLOGIST varchar(5) ;
	DECLARE vV_JOBCARD_TIME datetime ;
	DECLARE vV_REPORT_TIME datetime ;
	DECLARE vR_TYPIST varchar(5) ;
	DECLARE vR_LANGUAGE varchar(1) ;
	DECLARE vR_USERNAME varchar(15) ;
	DECLARE vR_COMPLETE int(11) ;
	DECLARE vR_COMPLETE_USER varchar(20) ;
	DECLARE vR_DOCIMGID bigint(20) ;
	DECLARE vA_AFTERHOURS int(11) ;
	DECLARE vA_WCA int(11) ;
	DECLARE vA_MVA int(11) ;
	DECLARE vA_BRANCCODE varchar(5) ;
	DECLARE vA_DEPARTMENT varchar(10) ;
	DECLARE vA_VAT_INV int(11) ;
	DECLARE vA_MOP varchar(1) ;
	DECLARE vA_OPERATOR varchar(5) ;
	DECLARE vA_HOSP_PATIENT int(11) ;
	DECLARE vA_HOSP_NUMBER varchar(15) ;
	DECLARE vA_EXPORTED int(11) ;
	DECLARE vA_EXPORT_DATE datetime ;
	DECLARE vA_FEEING_STATUS varchar(1) ;
	DECLARE vA_PRIMARY_DOC varchar(5) ;
	DECLARE vA_SECONDARY_DOC varchar(5) ;
	DECLARE vA_FEEING_TYPE varchar(1) ;
	DECLARE vA_BALANCE decimal(18,2) ;
	DECLARE vA_VAT decimal(18,2) ;
	DECLARE vA_COMMENT1 varchar(45) ;
	DECLARE vA_COMMENT2 varchar(45) ;
	DECLARE vA_HOLD int(11) ;
	DECLARE vA_DATE_ENTERED datetime ;
	DECLARE vA_PREGNANT int(11) ;
	DECLARE vA_AUTH varchar(100) ;
	DECLARE vA_FACTOR int(11) ;
	DECLARE vA_FEED_BY varchar(45) ;
	DECLARE vA_EXAM_DATE datetime ;
	DECLARE vA_URGENT int(11) ;
	DECLARE vA_WAITING int(11) ;
	DECLARE vA_DELIVER int(11) ;
	DECLARE vA_PAYING int(11) ;
	DECLARE vA_USERNAME varchar(45) ;
	DECLARE vA_BADDEB_OVERRIDE varchar(45) ;
	DECLARE vA_WARD varchar(5) ;
	DECLARE vA_COMPLETE int(11) ;
	DECLARE vA_CLAIM_STATUS int(11) ;
	DECLARE vA_PROMED_INITIALS varchar(10) ;
	DECLARE vA_SITE_ID varchar(5) ;
	DECLARE vA_BURNCD int(11) ;
	DECLARE vA_CD_COPIES int(11) ;
	DECLARE vA_CD_STATUS int(11) ;
	DECLARE vA_EMAIL int(11) ;
	DECLARE vA_LANEXPORT int(11) ;
	DECLARE vA_CANCELLED_BY varchar(45) ;
	DECLARE vA_ELIG_STATUS int(11) ;
	DECLARE vA_ICD10_STATUS varchar(1) ;
	DECLARE vA_HOSP_DOCTOR int(11) ;
	DECLARE vA_DOC_MEDIA varchar(10) ;
	DECLARE vA_EXCESSPAYMENT int(11) ;
	DECLARE vA_PATIENT_TOESTAND varchar(5) ;
	DECLARE vA_TELERAD_STATUS int(11) ;
	DECLARE vA_FLOW_GROUP varchar(1) ;
	DECLARE vA_FLOW_STATUS int(11) ;
	DECLARE vA_DESPATCH int(11) ;
	DECLARE vA_DESPATCH_FLOW int(11) ;
	DECLARE vA_CARD_STATUS int(11) ;
	DECLARE vA_INTERESTING int(11) ;
	DECLARE vA_PAT_REQUEST_CD int(11) ;
	DECLARE vA_DESPATCHED varchar(1) ;
	DECLARE vA_BREAST_FEEDING int(11) ;
	DECLARE vA_VIRT_CLAIM int(11) ;
	DECLARE vD_SUID varchar(64) ;
    DECLARE vE_SUID varchar(64) ;	
	DECLARE vD_DICOM_STATUS varchar(45) ;
	DECLARE vD_UPDATE_PENDING int(11) ;
	DECLARE vD_IMAGE_AVAILABLE int(11) ;
	DECLARE vM_HOME_ADD1 varchar(45) ;
	DECLARE vM_HOME_ADD2 varchar(45) ;
	DECLARE vM_HOME_ADD3 varchar(45) ;
	DECLARE vM_HOME_ADD4 varchar(45) ;
	DECLARE vM_HOME_CODE varchar(45) ;
	DECLARE vM_POSTAL_ADD1 varchar(45) ;
	DECLARE vM_POSTAL_ADD2 varchar(45) ;
	DECLARE vM_POSTAL_ADD3 varchar(45) ;
	DECLARE vM_POSTAL_ADD4 varchar(45) ;
	DECLARE vM_POSTAL_CODE varchar(45) ;
	DECLARE vM_EMPLY_ADD1 varchar(45) ;
	DECLARE vM_EMPLY_ADD2 varchar(45) ;
	DECLARE vM_EMPLY_ADD3 varchar(45) ;
	DECLARE vM_EMPLY_ADD4 varchar(45) ;
	DECLARE vM_EMPLY_CODE varchar(45) ;
	DECLARE vM_REL_ADD1 varchar(45) ;
	DECLARE vM_REL_ADD2 varchar(45) ;
	DECLARE vM_REL_ADD3 varchar(45) ;
	DECLARE vM_REL_ADD4 varchar(45) ;
	DECLARE vM_REL_CODE varchar(45) ;
	DECLARE vM_REL_TEL varchar(45) ;
	DECLARE vM_EMPLY_TEL varchar(45) ;
	DECLARE vM_HOME_TEL varchar(45) ;   
    DECLARE vE_EXAMCODE varchar(10) ;   
    DECLARE vE_MODALITY varchar(3) ;   
    
    DECLARE vF_FEED integer;
    DECLARE vF_LINE  integer;
    DECLARE vF_QTY  integer;
    DECLARE vF_SM_FLAG  integer;
    DECLARE vF_SM_CODE varchar(10);
    DECLARE vF_DESCRIPTION varchar(100);
    DECLARE vF_PRICE decimal(18,2);
    DECLARE vF_LINE_DATE timestamp;
    DECLARE vF_MIN  integer;
    DECLARE vF_MAX  integer;
    DECLARE vF_MANDATORY  char(1);
    DECLARE vF_STRUCTURE_LINE  integer;
    DECLARE vF_SEQUANCE  integer;
    DECLARE vF_COST   integer;
    DECLARE vF_DEPARTMENT  integer;
    DECLARE vF_DATE_ENTERED timestamp;
    DECLARE vF_PC_LOGINNAME varchar(80);
    DECLARE vF_PROMED_LOGINNAME  varchar(80);
    DECLARE vF_PC_HOSTNAME  varchar(80);
    DECLARE vF_PC_WINDESC  varchar(80);
    DECLARE vF_PAID_FLAG integer; 
    DECLARE vF_PAY_DENY_REASON  varchar(80);
    DECLARE vF_FUND_REF_NUMBER  varchar(80);
    DECLARE vF_PAID_AMOUNT decimal(18,2);
    DECLARE vF_MCP_IND varchar(2);
    DECLARE vF_PROMED_INITIALS varchar(10);
    DECLARE vF_STRUC_CODE varchar(10);
    DECLARE vF_F_TYPE integer;
    DECLARE vF_TARRIF_CODE varchar(10);

	DECLARE done INT DEFAULT FALSE;
	DECLARE v_pdb_id INT DEFAULT null;
	DECLARE v_acc_count INT DEFAULT 0;
    DECLARE v_teller INTEGER ;
    DECLARE v_accessionID bigint ;
    DECLARE v_visitid bigint ;
	DECLARE vUnmappedExamID bigint ;
    DECLARE v_docID bigint ;
    DECLARE v_saccessionNumber varchar(10) ;
	declare vRelationID bigint;
	declare vPatientID bigint;
	
	
	declare vAccFlowG_ID bigint;
	declare vAccFlowS_ID bigint;
	  DECLARE code CHAR(5) DEFAULT '00000';
  DECLARE msg TEXT;
	

	DECLARE mirgeacc CURSOR FOR SELECT	TMA.ACC_CODE, TMA.P_UID, TMA.P_SURNAME, TMA.P_NAME, TMA.P_ID, TMA.P_SITE_ID, 
										TMA.P_INITIALS, TMA.P_TITLE, TMA.P_DOB, TMA.P_DEP_NO, TMA.P_NON_SA_ID, TMA.P_VIP, 
                                        TMA.P_SMOKING, TMA.P_CONSENT, TMA.P_PARENTCONSENT, TMA.P_DATE_ENTERED, 
                                        TMA.P_GENDER, TMA.P_CELLPHONE, TMA.P_LANGUAGE, TMA.P_ALLERGIES, TMA.P_WEIGHT, 
                                        TMA.P_VALVES, TMA.P_ASHMA, TMA.P_PREGNANT, TMA.P_PACEMAKER, TMA.P_METAL_IN_HEAD, 
                                        TMA.P_CLIPS, TMA.P_OCCUPATION, TMA.P_EMAIL, TMA.P_FORCENUMBER, 
                                        TMA.P_COMPANYNUMBER, TMA.P_PATIENTINFO, TMA.P_FAX, TMA.P_COMMS_PREF, 
                                        TMA.P_COMPANY_NAME, TMA.M_MED_AID, TMA.M_MED_AID_REF, TMA.M_MED_AID_CLAIM, 
                                        TMA.M_TITLE, TMA.M_INITIALS, TMA.M_NAME, TMA.M_ID, TMA.M_CELLPHONE, 
                                        TMA.M_RELATION, TMA.M_NOK_NAME, TMA.M_NOK_RELATION, TMA.M_NOK_TEL, 
                                        TMA.M_EMPLOYER, TMA.M_OCCUPATION, TMA.M_WORK_DEPT, TMA.M_NUM_DEPENDANTS, 
                                        TMA.M_DATE_ENTERED, TMA.M_FAX, TMA.M_DOB, TMA.M_EMAIL, TMA.M_FORCE_NUMBER, 
                                        TMA.M_COMPANY_NUMBER, TMA.M_VAT_NUMBER, TMA.M_NON_SA_ID, TMA.M_MED_AID_PLAN, 
                                        TMA.M_CONSENT, TMA.WCA_EMPLOYER, TMA.WCA_EMPOYER_TEL, TMA.WCA_OCCUPATION, 
                                        TMA.WCA_DEPARTMENT, TMA.WCA_COMPANY_NUMBER, TMA.WCA_DOI, 
                                        TMA.WCA_WCA_CLAIM_NUMBER, TMA.WCA_CLAIM_TYPE, TMA.WCA_DATE_ENTERED, 
                                        TMA.WCA_CLAIM_REF_NUM, TMA.V_EXAM_ADDED, TMA.V_REPORT_STATUS, 
                                        TMA.V_JOBCARD_STATUS, TMA.V_RADIOLOGIST, TMA.V_RADIOGRAPHER, 
                                        TMA.V_JUNIOR_RADIOLOGIST, TMA.V_JOBCARD_TIME, TMA.V_REPORT_TIME, TMA.R_TYPIST, 
                                        TMA.R_LANGUAGE, TMA.R_USERNAME, TMA.R_COMPLETE, TMA.R_COMPLETE_USER, 
                                        TMA.R_DOCIMGID, TMA.A_AFTERHOURS, TMA.A_WCA, TMA.A_MVA, TMA.A_BRANCCODE, 
                                        TMA.A_DEPARTMENT, TMA.A_VAT_INV, TMA.A_MOP, TMA.A_OPERATOR, TMA.A_HOSP_PATIENT, 
                                        TMA.A_HOSP_NUMBER, TMA.A_EXPORTED, TMA.A_EXPORT_DATE, TMA.A_FEEING_STATUS, 
                                        TMA.A_PRIMARY_DOC, TMA.A_SECONDARY_DOC, TMA.A_FEEING_TYPE, TMA.A_BALANCE, 
                                        TMA.A_VAT, TMA.A_COMMENT1, TMA.A_COMMENT2, TMA.A_HOLD, TMA.A_DATE_ENTERED, 
                                        TMA.A_PREGNANT, TMA.A_AUTH, TMA.A_FACTOR, TMA.A_FEED_BY, TMA.A_EXAM_DATE, 
                                        TMA.A_URGENT, TMA.A_WAITING, TMA.A_DELIVER, TMA.A_PAYING, TMA.A_USERNAME, 
                                        TMA.A_BADDEB_OVERRIDE, TMA.A_WARD, TMA.A_COMPLETE, TMA.A_CLAIM_STATUS,
                                        TMA.A_PROMED_INITIALS, TMA.A_SITE_ID, TMA.A_BURNCD, TMA.A_CD_COPIES, 
                                        TMA.A_CD_STATUS, TMA.A_EMAIL, TMA.A_LANEXPORT, TMA.A_CANCELLED_BY, 
                                        TMA.A_ELIG_STATUS, TMA.A_ICD10_STATUS, TMA.A_HOSP_DOCTOR, TMA.A_DOC_MEDIA, 
                                        TMA.A_EXCESSPAYMENT, TMA.A_PATIENT_TOESTAND, TMA.A_TELERAD_STATUS, 
                                        TMA.A_FLOW_GROUP, TMA.A_FLOW_STATUS, TMA.A_DESPATCH, TMA.A_DESPATCH_FLOW, 
                                        TMA.A_CARD_STATUS, TMA.A_INTERESTING, TMA.A_PAT_REQUEST_CD, TMA.A_DESPATCHED, 
                                        TMA.A_BREAST_FEEDING, TMA.A_VIRT_CLAIM, TMA.D_SUID, TMA.D_DICOM_STATUS, 
                                        TMA.D_UPDATE_PENDING, TMA.D_IMAGE_AVAILABLE, TMA.M_HOME_ADD1, TMA.M_HOME_ADD2, 
                                        TMA.M_HOME_ADD3, TMA.M_HOME_ADD4, TMA.M_HOME_CODE, TMA.M_POSTAL_ADD1, 
                                        TMA.M_POSTAL_ADD2, TMA.M_POSTAL_ADD3, TMA.M_POSTAL_ADD4, TMA.M_POSTAL_CODE, 
                                        TMA.M_EMPLY_ADD1, TMA.M_EMPLY_ADD2, TMA.M_EMPLY_ADD3, TMA.M_EMPLY_ADD4, 
                                        TMA.M_EMPLY_CODE, TMA.M_REL_ADD1, TMA.M_REL_ADD2, TMA.M_REL_ADD3, TMA.M_REL_ADD4, 
                                        TMA.M_REL_CODE, TMA.M_REL_TEL, TMA.M_EMPLY_TEL, TMA.M_HOME_TEL  
								FROM tmp_migrate_account TMA;
    
    DECLARE mirgeexam CURSOR FOR SELECT ACC_CODE,EXAM_CODE,MODALITY_CODE,SUID  from tmp_migrate_account_exams;
    
    declare mirgefees cursor for SELECT ACC_CODE, FEED, LINE, QTY, SM_FLAG ,  SM_CODE ,  DESCRIPTION ,  PRICE ,  LINE_DATE ,  MIN ,  MAX ,  MANDATORY ,  STRUCTURE_LINE ,  SEQUANCE ,  COST ,  DEPARTMENT ,  DATE_ENTERED ,  PC_LOGINNAME ,  
										PROMED_LOGINNAME ,  PC_HOSTNAME ,  PC_WINDESC ,  PAID_FLAG ,  PAY_DENY_REASON ,  FUND_REF_NUMBER ,  
                                        PAID_AMOUNT ,  MCP_IND ,  PROMED_INITIALS ,  STRUC_CODE ,  F_TYPE ,  TARRIF_CODE  
                                        FROM  tmp_migrate_account_fees ;

    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;            
/*	  declare msg VARCHAR(128);
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN 
 /*need min mysql 5.6.4 
	GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
    set msg = substring(concat('[DHOS]:',msg),1,128);   	
		ROLLBACK;
    set @G_transaction_started = 0;
    signal sqlstate '45000' SET MESSAGE_TEXT = msg;
 END; MESSAGE_TEXT = concat("Transaction Rollback for migration_complete.SQL Exception occured.",@p2);   	
	 END;
	  SET autocommit = 0;
   if ((@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
     START TRANSACTION;  
     set @G_transaction_started = 1;
   end; else begin
    set @G_transaction_started = @G_transaction_started + 1;
   end; end if;
	*/ 
	set vUnmappedExamID = null;
    select ipkExamID into vUnmappedExamID from exams where sExamCode = 'UNMAPED';
	
	SELECT ipkAccountFlowStatusID into vAccFlowS_ID FROM account_flow_statuses where sStatusRule = 'AUT';
	SELECT ipkAccountFlowGroupID into vAccFlowG_ID FROM account_flow_group where sCode = 'AUT';
	
    OPEN mirgeacc;
    SET done = FALSE ;

    read_loop: LOOP

		FETCH mirgeacc INTO	vACC_CODE, vP_UID, vP_SURNAME, vP_NAME, vP_ID, vP_SITE_ID, vP_INITIALS, vP_TITLE, vP_DOB, vP_DEP_NO,
							vP_NON_SA_ID, vP_VIP, vP_SMOKING, vP_CONSENT, vP_PARENTCONSENT, vP_DATE_ENTERED, vP_GENDER, 
                            vP_CELLPHONE, vP_LANGUAGE, vP_ALLERGIES, vP_WEIGHT, vP_VALVES, vP_ASHMA, vP_PREGNANT, vP_PACEMAKER,
                            vP_METAL_IN_HEAD, vP_CLIPS, vP_OCCUPATION, vP_EMAIL, vP_FORCENUMBER, vP_COMPANYNUMBER, 
                            vP_PATIENTINFO, vP_FAX, vP_COMMS_PREF, vP_COMPANY_NAME, vM_MED_AID, vM_MED_AID_REF, 
                            vM_MED_AID_CLAIM, vM_TITLE, vM_INITIALS, vM_NAME, vM_ID, vM_CELLPHONE, vM_RELATION, vM_NOK_NAME,
                            vM_NOK_RELATION, vM_NOK_TEL, vM_EMPLOYER, vM_OCCUPATION, vM_WORK_DEPT, vM_NUM_DEPENDANTS, 
                            vM_DATE_ENTERED, vM_FAX, vM_DOB, vM_EMAIL, vM_FORCE_NUMBER, vM_COMPANY_NUMBER, vM_VAT_NUMBER,
                            vM_NON_SA_ID, vM_MED_AID_PLAN, vM_CONSENT, vWCA_EMPLOYER, vWCA_EMPOYER_TEL, vWCA_OCCUPATION, 
                            vWCA_DEPARTMENT, vWCA_COMPANY_NUMBER, vWCA_DOI, vWCA_WCA_CLAIM_NUMBER, vWCA_CLAIM_TYPE, 
                            vWCA_DATE_ENTERED, vWCA_CLAIM_REF_NUM, vV_EXAM_ADDED, vV_REPORT_STATUS, vV_JOBCARD_STATUS, 
                            vV_RADIOLOGIST, vV_RADIOGRAPHER, vV_JUNIOR_RADIOLOGIST, vV_JOBCARD_TIME, vV_REPORT_TIME, vR_TYPIST,
                            vR_LANGUAGE, vR_USERNAME, vR_COMPLETE, vR_COMPLETE_USER, vR_DOCIMGID, vA_AFTERHOURS, vA_WCA, vA_MVA,
                            vA_BRANCCODE, vA_DEPARTMENT, vA_VAT_INV, vA_MOP, vA_OPERATOR, vA_HOSP_PATIENT, vA_HOSP_NUMBER,
                            vA_EXPORTED, vA_EXPORT_DATE, vA_FEEING_STATUS, vA_PRIMARY_DOC, vA_SECONDARY_DOC, vA_FEEING_TYPE,
							vA_BALANCE, vA_VAT, vA_COMMENT1, vA_COMMENT2, vA_HOLD, vA_DATE_ENTERED, vA_PREGNANT, vA_AUTH, 
                            vA_FACTOR, vA_FEED_BY, vA_EXAM_DATE, vA_URGENT, vA_WAITING, vA_DELIVER, vA_PAYING, vA_USERNAME, 
                            vA_BADDEB_OVERRIDE, vA_WARD, vA_COMPLETE, vA_CLAIM_STATUS, vA_PROMED_INITIALS, vA_SITE_ID, 
                            vA_BURNCD, vA_CD_COPIES, vA_CD_STATUS, vA_EMAIL, vA_LANEXPORT, vA_CANCELLED_BY, vA_ELIG_STATUS,
                            vA_ICD10_STATUS, vA_HOSP_DOCTOR, vA_DOC_MEDIA, vA_EXCESSPAYMENT, vA_PATIENT_TOESTAND,
                            vA_TELERAD_STATUS, vA_FLOW_GROUP, vA_FLOW_STATUS, vA_DESPATCH, vA_DESPATCH_FLOW, vA_CARD_STATUS,
                            vA_INTERESTING, vA_PAT_REQUEST_CD, vA_DESPATCHED, vA_BREAST_FEEDING, vA_VIRT_CLAIM, vD_SUID,
                            vD_DICOM_STATUS, vD_UPDATE_PENDING, vD_IMAGE_AVAILABLE, vM_HOME_ADD1, vM_HOME_ADD2, vM_HOME_ADD3,  
                            vM_HOME_ADD4, vM_HOME_CODE, vM_POSTAL_ADD1, vM_POSTAL_ADD2, vM_POSTAL_ADD3, vM_POSTAL_ADD4,
                            vM_POSTAL_CODE, vM_EMPLY_ADD1, vM_EMPLY_ADD2, vM_EMPLY_ADD3, vM_EMPLY_ADD4, vM_EMPLY_CODE, 
                            vM_REL_ADD1, vM_REL_ADD2, vM_REL_ADD3, vM_REL_ADD4, vM_REL_CODE, vM_REL_TEL, vM_EMPLY_TEL, 
                            vM_HOME_TEL;

        IF done THEN begin
		  LEAVE read_loop;
		end; END IF;
		
		update tmp_migrate_account_exams set SUID = vD_SUID where ACC_CODE = vACC_CODE; /*Make sure all exams has the correct suid*/
        
		

        select count(ipkAccountID) into v_acc_count from  accounts where sAccountCode = vACC_CODE;

        if (v_acc_count <= 0) then begin
		     set v_pdb_id = null;
		
             select ipkPatientID into v_pdb_id from  patients where sUID = vP_UID;
		
			 /*select vACC_CODE,vP_UID,vP_SURNAME;*/
			/*AS nie bestaan skep, anders ignoreer*/
			if (v_pdb_id <= 0) then begin
                select ( 'patient not found ');			
				set v_pdb_id = null;
		
			end; end if;
        
			CALL PatientCaptureMigrate(null, v_pdb_id, vACC_CODE, vM_MED_AID, vM_MED_AID_PLAN, vM_DOB, vM_VAT_NUMBER, vM_TITLE, 
								vM_INITIALS, vM_INITIALS, vM_NAME, vM_NON_SA_ID, vP_CONSENT, vM_MED_AID_REF, vM_ID, vM_CELLPHONE, 
                                vM_NOK_TEL, vM_FAX, vM_EMAIL, vM_POSTAL_ADD1, vM_POSTAL_ADD2, vM_POSTAL_ADD3, vM_POSTAL_ADD4,
                                vM_POSTAL_CODE, vM_HOME_ADD1, vM_HOME_ADD2, vM_HOME_ADD3, vM_HOME_ADD4, vM_HOME_CODE,
                                vM_REL_ADD1, vM_REL_ADD2, vM_REL_ADD3, vM_REL_ADD4, vM_REL_CODE, vM_EMPLY_TEL, vM_HOME_TEL, 
                                vP_TITLE, vP_SURNAME, vP_GENDER, vP_NAME, vP_INITIALS, vP_DOB, vP_ID, vP_NON_SA_ID, vM_RELATION, 
                                vP_DEP_NO, vP_OCCUPATION, vP_ASHMA, vP_ALLERGIES, vP_EMAIL, '', vP_COMPANYNUMBER, vP_SMOKING, 
                                vP_FAX, vP_CELLPHONE, vP_PATIENTINFO, vP_COMMS_PREF, '', '', vP_VIP, vP_PACEMAKER, vA_BRANCCODE,
                                vA_WARD, vA_WAITING, vA_AFTERHOURS, vA_PRIMARY_DOC, vA_SECONDARY_DOC, vA_COMMENT1, 
                                vA_MOP, vA_HOSP_PATIENT, vA_HOSP_NUMBER, vA_AUTH, vA_PREGNANT, vA_BREAST_FEEDING, 0, 
                                vA_PATIENT_TOESTAND, vA_VAT_INV, vA_URGENT, vA_BURNCD, vA_CD_COPIES, vA_EMAIL, vA_MVA, vA_WCA,
                                vWCA_DOI, vWCA_WCA_CLAIM_NUMBER, 0, '', vA_DESPATCH, 0, vA_HOLD, vA_USERNAME,0,vM_EMPLOYER,'',0,0,0,'',
                                vM_EMPLY_ADD1,vM_EMPLY_ADD2,vM_EMPLY_ADD3,vM_EMPLY_ADD4,vM_EMPLY_CODE,vP_UID);
        		        
			SELECT A.ipkAccountID into vAccountID FROM accounts A WHERE A.sAccountCode = vACC_CODE;
            if ((vAccountID is not null) and (vAccountID > 0)) then begin
			    update accounts set sUserName = 'MIGRATE',ifkAccountFlowGroupID = vAccFlowG_ID,ifkAccountFlowStatusID = vAccFlowS_ID where ipkAccountID = vAccountID;
				update accounts set ifksiteid = 1 where ipkAccountID = vAccountID and ifksiteid is null;
				IF not EXISTS (SELECT ipkAccessionID from account_accessions where ifkAccountID = vAccountID) THEN BEGIN	
				  CALL AccessionCreate(vAccountID,v_accessionID, v_saccessionNumber);
                  update account_accessions set sAccessionNumber = vACC_CODE,ifkAccountFlowGroupID = vAccFlowG_ID,ifkAccountFlowStatusID = vAccFlowS_ID where ifkAccountID = vAccountID;
				end; else begin
                  SELECT ipkAccessionID into v_accessionID from account_accessions where ifkAccountID = vAccountID;
                end; END IF;  
                
                IF not EXISTS (SELECT ipkVisitID from visit where ifkAccountID = vAccountID and ifkAccessionID = v_accessionID) THEN BEGIN
					INSERT INTO visit(ifkAccountID, dExaminationDate, dDateEntered, sUserName,ifkAccessionID)
					VALUES(vAccountID, vA_EXAM_DATE, vA_DATE_ENTERED, 'MIGRATE',v_accessionID);
				end; end if; 
             
                 update visit set dDateEntered = vA_DATE_ENTERED, dExaminationDate = vA_EXAM_DATE where ifkAccountID = vAccountID;
				 update accounts set dExamDate = vA_EXAM_DATE,dDateEntered = vA_DATE_ENTERED where ipkAccountID = vAccountID;
				
				 update account_accessions set sAccessionNumber = vACC_CODE,dDateEntered = vA_DATE_ENTERED where ifkAccountID = vAccountID;
				 
				update docimg_documents 
					set ifkAccountID = vAccountID ,dDate_entered = vA_DATE_ENTERED
				where  sRef_number = vACC_CODE  and sDoc_Type = 'REPORT'
					and ifkAccountID is null;
	
				set v_teller = 0;
				select count(ifkAccountID) into v_teller from docimg_documents where ifkAccountID = vAccountID;
				select max(ipkdoc_id) into v_docID  from docimg_documents where ifkAccountID = vAccountID;

				if (v_teller >= 1) then begin
					set v_teller = 0;
					select count(ifkAccountID) into v_teller from reports where ifkAccountID = vAccountID;
					if ((v_teller <= 0) or (v_teller is null)) then begin

						insert into reports(ipkReportID,ifkAccountID,ifkAccessionID,ifkdoc_id,dDateEntered,dDateStarted,dDateEnded) values (0,vAccountID,v_accessionID,v_docID,vA_DATE_ENTERED,vA_DATE_ENTERED,vA_DATE_ENTERED);
					end; end if;
				end; end if;
            end; end if;
            if (subdate(current_date, 1) > vA_DATE_ENTERED) then begin
			   delete from current_accounts where ifkAccountID = vAccountID;
			   update accounts set bExported = 1 where ipkAccountID = vAccountID;
			   update hl7_sending_list set bHandle = 1 where  ifkAccountID = vAccountID;
			end; end if;
		end;  else begin
		  SELECT A.ipkAccountID into vAccountID FROM accounts A WHERE A.sAccountCode = vACC_CODE;
          call migration_report_only(vACC_CODE);
		  	 
	 
		  select p.ipkPatientID,p.ifkRelationID into vPatientID ,vRelationID from accounts a, patients p where a.sAccountCode = vACC_CODE and a.ifkPatientID = p.ipkPatientID;
		  if ((vRelationID is null) or (vRelationID <= 0 )) then begin
		      select ipkRelationID into vRelationID from relations where sCode = vM_RELATION;
			  if ((vRelationID > 0 )) then begin
			     update patients set ifkRelationID = vRelationID where ipkPatientID = vPatientID;
			  end; end if;	 
		  end; end if;
		  set vRelationID = 0;
		  SELECT ipkReferringDoctorID into vRelationID FROM referring_doctors where sCode = vA_PRIMARY_DOC;
		  if ((vRelationID > 0 )) then begin
			 update accounts set ifkPrimaryReferringDoctorID = vRelationID where ipkAccountID = vAccountID;
		  end; end if;	 
		  
		  set vRelationID = 0;
		  SELECT ipkReferringDoctorID into vRelationID FROM referring_doctors where sCode = vA_SECONDARY_DOC;
		  if ((vRelationID > 0 )) then begin
			 update accounts set ifkSecondaryReferringDoctorID = vRelationID where ipkAccountID = vAccountID;
		  end; end if;	 
		   
		   
		  /*Verwyder die dat dit nie weer gedoen word want sisteem het dit klaar*/
		  /*delete from tmp_migrate_account_exams where ACC_CODE =  vACC_CODE; *//*Let it be doen again for re-migration sake*/
		  delete from tmp_migrate_account_fees where ACC_CODE =  vACC_CODE; 
		  update hl7_sending_list set bHandle = 1 where  ifkAccountID = vAccountID;
		  update account_accessions set sAccessionNumber = vACC_CODE,ifkAccountFlowGroupID = vAccFlowG_ID,ifkAccountFlowStatusID = vAccFlowS_ID,dDateEntered = vA_DATE_ENTERED where ifkAccountID = vAccountID;
		  
        end; end if;
        SET done = FALSE ;
	END LOOP read_loop;

	CLOSE mirgeacc;
    

    OPEN mirgeexam;
    SET done = FALSE ;

    read_loop_exams: LOOP

		FETCH mirgeexam INTO vACC_CODE,vE_EXAMCODE ,vE_MODALITY,vE_SUID ;
        IF done THEN
		  LEAVE read_loop_exams;
		END IF;
        
        set vAccountID = 0; 
        select ipkAccountID,dExamDate into vAccountID,vA_EXAM_DATE from  accounts where sAccountCode = vACC_CODE;
        if ((vAccountID > 0) and (vAccountID is not null)) then begin
               select max(ipkAccessionID) into v_accessionID from account_accessions where ifkAccountID = vAccountID; 
               IF EXISTS (SELECT ipkExamID from exams where sExamCode = vE_EXAMCODE) THEN BEGIN	
                  delete from account_exams where ifkexamid = vUnmappedExamID and ifkaccountid = vAccountID;
				  call PatientExamCaptureMigrate(vACC_CODE,vE_MODALITY,vE_EXAMCODE,'',vA_EXAM_DATE,v_accessionID);
				  
               end; else begin
		          call PatientExamCaptureMigrate(vACC_CODE,'CR','UNMAPED','',vA_EXAM_DATE,v_accessionID); /*'CHEST'*/
		       end; end if;  
			   update dicom_worklist set ihandled = 1, sStudyInstanceUID = vE_SUID where ifkAccountID = vAccountID;
			   update hl7_sending_list set bHandle = 1 where  ifkAccountID = vAccountID;
        end; end if;

        SET done = FALSE ; 
	END LOOP read_loop_exams;
        
	CLOSE mirgeexam;
    
    OPEN mirgefees;
    SET done = FALSE ;

    read_loop_fees: LOOP

		FETCH mirgefees INTO vACC_CODE, vF_FEED , vF_LINE  ,     vF_QTY  ,     vF_SM_FLAG  ,     vF_SM_CODE ,     vF_DESCRIPTION ,     vF_PRICE ,
							vF_LINE_DATE ,     vF_MIN  ,     vF_MAX  ,    vF_MANDATORY  ,     vF_STRUCTURE_LINE  ,     vF_SEQUANCE  ,
							vF_COST   ,     vF_DEPARTMENT  ,     vF_DATE_ENTERED ,     vF_PC_LOGINNAME ,     vF_PROMED_LOGINNAME,     vF_PC_HOSTNAME ,
							vF_PC_WINDESC ,     vF_PAID_FLAG ,     vF_PAY_DENY_REASON  ,     vF_FUND_REF_NUMBER ,     vF_PAID_AMOUNT ,     vF_MCP_IND,
							vF_PROMED_INITIALS,     vF_STRUC_CODE,     vF_F_TYPE ,     vF_TARRIF_CODE ;
        IF done THEN begin
		  LEAVE read_loop_fees;
		end; END IF;

		set vAccountID = 0; 
        select ipkAccountID into vAccountID from  accounts where sAccountCode = vACC_CODE;
        if ((vAccountID > 0) and (vAccountID is not null)) then begin
           select max(ipkAccessionID) into v_accessionID from account_accessions where ifkAccountID = vAccountID; 
			select max(ipkVisitID) into v_visitid from visit where ifkAccountID = vAccountID;
              if (vF_MANDATORY = 'M') then
                set vF_MANDATORY = '1';
              else 
                 set vF_MANDATORY = '0';
              end if;   
           INSERT INTO fees (ipkFeeID,ifkAccountID,ifkVisitID,fUnitPrice,dLineDate,dDateEntered,
					fPaidAmount,iReference,iFeeLine,iQuantity,sSMCode,iMinimum,iMaximum,
					iStructureLine,iSequence,fCost,ifkDepartmentID,bPaidFlag,iFeeLineID,
					sMCPIND,sPromedInitials,sStrucCode,sType,sTarrifCode,bFeed,
					sDescription,sFunderReferenceNumber,sSMFlag,sMandatory,sPCLoginName,
					sPromedLoginName,sPCHostName,sPCWinDescription,sPayDenyReason,bCommentLine,
					fVATAmount)
					VALUES
						(0,vAccountID,v_visitid,(vF_PRICE),vF_LINE_DATE,
						CURRENT_TIMESTAMP,vF_PAID_AMOUNT,0,
						vF_LINE,vF_QTY,vF_SM_CODE,
						vF_MIN,vF_MAX,vF_STRUCTURE_LINE,
						vF_SEQUANCE,(vF_COST/100),vF_DEPARTMENT,
						vF_PAID_FLAG,vF_LINE,vF_MCP_IND,
						vF_PROMED_INITIALS,vF_STRUC_CODE,vF_F_TYPE,
						vF_TARRIF_CODE,vF_FEED,vF_DESCRIPTION,
						vF_FUND_REF_NUMBER,vF_SM_FLAG,vF_MANDATORY,
						vF_PC_LOGINNAME,vF_PROMED_LOGINNAME,vF_PC_HOSTNAME,
						vF_PC_WINDESC,vF_PAY_DENY_REASON,0,0);

        end; end if;

        SET done = FALSE ; 
	END LOOP read_loop_fees;
        
	CLOSE mirgefees;
/*	COMMIT;*/
    
END$$

DELIMITER ;

