USE `promed`;
DROP procedure IF EXISTS `DebtorStatementLineAdd`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DebtorStatementLineAdd`(in  v_DebtorTransactionType bigint(20) ,in v_TaxType integer,
in  v_AccountID bigint(20) ,
in  v_dLineDate timestamp ,
in  v_iQuantity integer,
in  v_sDescription varchar(100) ,
in  v_sTarrifCode varchar(10) ,
in  v_sNappiCode varchar(10) ,
in  v_fAmount decimal(18,2) ,
in  v_fVatAmount decimal(18,2) ,
in  v_fVatPerc decimal(18,2),
in  v_sStructureCode varchar(10),
in  v_CapturedBy bigint(20),
in v_BatchNumber varchar(10),
in v_BatchItemNumber integer ,
in v_ReceiptCode varchar(10),
in v_Payer varchar(20),
in v_ReceiptID bigint,
in v_iMethodOfPayment integer,out v_iStatementID bigint
)
BEGIN

  /*
    developer : johannes pretorius
    date : 28 feb 2018
    purpose : 
        to control the logic in adding journal/statement lines. The logic and rules are based on the TYPE of line being given by vsLineType
        Note this is just for entries into debtor_statements and debtor_statement_audit
        
   v_DebtorTransactionType  is used to lookup code in debtor_transaction_types and then the code is placed in vsLineType
   this vsLineType can be of types
      FEEADJ : Fee Adjustment (can be a normal Invoice line being added also)
      WRTOFF : Write off 
      BADWOFF : Bad Debt write off
      DISCNT : Discount
      TRNSFR : Transfer
      REFUND : Refund
      CHEQUES : Rd Cheques
      NOTE : Note
  */
 
declare v_iLineNumber int(11);
declare vsLineType varchar(10);

declare v_bVatCreditNote smallint;
declare v_bDebitAccount smallint;
declare v_bVatCharge smallint;
declare v_sNextTM CHAR(1);

declare v_ifkFeeMedicalAidID BIGINT;
declare v_ifkFeeMedicalAidPlanID BIGINT;
declare v_sPatientFirtname VARCHAR(45);
declare v_sPatientSurname VARCHAR(45);
declare v_sPatientIDNumber VARCHAR(13);
declare v_dPatientDOB date;
declare v_sMemberFirstname VARCHAR(45);
declare v_sMemberSurname VARCHAR(45);
declare v_sMemberIntials VARCHAR(10);
declare v_sMemberIDNumber VARCHAR(13);
declare v_dMemberDOB date;
declare v_sStructureCode VARCHAR(10);
declare v_sDiagnosesCodes VARCHAR(80);
declare v_ifkFeeingTypeID bigint;
declare v_fFilmUsage integer;
declare v_ifkRadiologistID bigint;
declare v_ifkRadiographerID bigint;
declare v_ifkPrimaryDoctorID bigint;
declare v_ifkSecondaryDoctorID bigint;
declare v_iPatientAge integer;
declare v_SrcBalance decimal(18,2);
declare v_bMoneyMovement smallint;
declare v_bWriteOff smallint;
declare vVatExclWaarde decimal(18,2);
declare v_SuspendID bigint;
declare v_iStatementUidID bigint;
declare v_SuspendLineNum bigint;

  declare vFiscalYear integer;
  declare vFiscalMonth  integer;
  declare vFiscalQuarter  integer;
  declare vRealFiscalYear integer;
  declare vRealFiscalMonth  integer;
  declare vRealFiscalQuarter  integer;  

  declare vPracID bigint;
  declare vSiteID bigint;
  declare vBranchID bigint;
  
  



declare v_writeVatDetLine smallint;
 declare msg VARCHAR(128);
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
 BEGIN 
 /*need min mysql 5.6.4 */
	GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
    set msg = substring(concat('[DSLA]:',msg),1,128);   	
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
 
set v_writeVatDetLine = 0;

 if (v_iMethodOfPayment <= 0 ) then begin
   set v_iMethodOfPayment =  null;
 end; end if;

select IFNULL(max(iLineNumber), 0) into v_iLineNumber from debtor_statements where ifkAccountID = v_AccountID;

set v_iLineNumber = v_iLineNumber + 1;

select sTransactionTypeCode,bVatCharge,bDebitAccount,bVatCreditNote,bMoneyMovement,bWriteOff into vsLineType,v_bVatCharge,v_bDebitAccount,v_bVatCreditNote,v_bMoneyMovement,v_bWriteOff from debtor_transaction_types where ipkDebtorTransactionType = v_DebtorTransactionType;

select a.ifkFeeMedicalAidID,a.ifkFeeMedicalAidPlanID,p.sName,p.sSurname,p.sIDNumber,p.dDateOfBirth,m.sName,m.sSurname,m.sInitials,m.sIDNumber,
		m.dMemberDateOfBirth ,a.ifkFeeingTypeID,a.ifkPrimaryReferringDoctorID,a.ifkSecondaryReferringDoctorID,DATE_FORMAT(NOW(), '%Y') - DATE_FORMAT(P.dDateOfBirth, '%Y') - (DATE_FORMAT(NOW(), '00-%m-%d') < DATE_FORMAT(P.dDateOfBirth, '00-%m-%d')),
		a.fBalance
   into v_ifkFeeMedicalAidID,v_ifkFeeMedicalAidPlanID,v_sPatientFirtname,v_sPatientSurname,v_sPatientIDNumber,v_dPatientDOB,v_sMemberFirstname,v_sMemberSurname,v_sMemberIntials,
		v_sMemberIDNumber,v_dMemberDOB,v_ifkFeeingTypeID,v_ifkPrimaryDoctorID,v_ifkSecondaryDoctorID,v_iPatientAge,v_SrcBalance
  from accounts a, patients p, members m
  where a.ifkpatientid = p.ipkpatientid
  and m.ipkmemberid = a.ifkmemberid
  and a.ipkaccountid = v_AccountID;
  
SELECT GROUP_CONCAT(i.sICD10Code SEPARATOR  ',') into v_sDiagnosesCodes FROM debtor_statement_icd10 d,icd_10 i
where ifkaccountid = v_AccountID
and iStatementLineNumber = v_iLineNumber 
and i.ipkICD10ID = d.ifkICD10ID
order by iLineNumber;

  set v_writeVatDetLine = v_bVatCharge;
 CASE vsLineType
	WHEN  'FEEADJ' THEN
		set v_sNextTM = 'N';
	WHEN 'WRTOFF' THEN
		SET v_sNextTM = 'S';
  
	WHEN 'BADWOFF' THEN
		SET v_sNextTM = 'N';
  
	WHEN 'DISCNT' THEN
		SET v_sNextTM = 'N';
/*        set v_writeVatDetLine = 1;  */
         
	WHEN 'TRNSFR' THEN
		SET v_sNextTM = 'N';
/*        set v_writeVatDetLine = 1;  */
         
	WHEN 'REFUND' THEN
		SET v_sNextTM = 'S';
        
	WHEN 'CHEQUES' THEN
		SET v_sNextTM = 'F';
	WHEN 'NOTE' THEN
		SET v_sNextTM = 'S';
	ELSE
		SET v_sNextTM = 'F';
 END CASE;
if ((v_bWriteOff = 1) and  ((v_SrcBalance < 0) or (v_SrcBalance < (v_fAmount)))) then begin
   signal sqlstate '45000'
   SET MESSAGE_TEXT = "Writeoff value larger than account Balance.";   
 end; end if;
  set vVatExclWaarde = (v_fAmount -  v_fVatAmount);
   set v_SuspendLineNum = v_BatchItemNumber;
   if (v_bMoneyMovement = 1) then begin /*Entry that affects the moneymovemnt table */
     CALL DebtorSuspensLineAdd(v_BatchNumber, current_timestamp,v_Payer, v_sDescription, -1 * v_fAmount,v_dLineDate,v_Capturedby,v_ReceiptID,v_accountid,v_iMethodOfPayment,v_DebtorTransactionType,v_ReceiptCode, v_SuspendID);
     select iBatchItemNumber into v_SuspendLineNum from debtor_suspense where ipkDebtorSuspensID = v_SuspendID;	 
	 CALL DebtorEventCapture(v_accountid, v_Capturedby, vsLineType, v_sDescription,null);
   end; end if;
   
/*Update running total before createing statment line*/
   select a.ifkSiteID,s.ifkPracticeInfoID,a.ifkBranchID into vSiteID,vPracID,vBranchID  from accounts a,sites s where a.ipkAccountID = v_AccountID and a.ifkSiteID  = s.ipkSiteID;
   call DebtorSaveRunningTotals(v_DebtorTransactionType,vPracID,vSiteID,vBranchID,cast(v_dLineDate as date),current_date,v_iMethodOfPayment,v_fAmount,v_fVatAmount,(v_fAmount - v_fVatAmount));
	 
/*Create statement line*/
    call DebtorPracticeFiscalInfoForDate(vPracID,v_dLineDate,vFiscalYear,vFiscalQuarter,vFiscalMonth); 
	call DebtorPracticeFiscalInfoForDate(vPracID,current_date,vRealFiscalYear,vRealFiscalQuarter,vRealFiscalMonth); 
	
	INSERT INTO debtor_statements (ipkStatementEntryID,ifkDebtorTransactionType,ifkAccountID,iLineNumber,dLineDate,
									sDescription,sTarrifCode,sNappiCode,dUpdateDateTime,fAmount,fVatAmount,fVatPerc,sStructureCode,
									ifkCapturedBy,iQty,ifkMethodOfPaymentID,fAmountExclVat,
									iRealFiscalMonth,iRealFiscalYear,iRealFiscalQuarter,iLineFiscalYear,iLineFiscalMonth,iLineFiscalQuarter) 
                                    VALUES
								  (0,v_DebtorTransactionType,v_AccountID,v_iLineNumber,v_dLineDate,v_sDescription,v_sTarrifCode,v_sNappiCode,
									current_timestamp,v_fAmount,v_fVatAmount,v_fVatPerc,v_sStructureCode,v_CapturedBy,v_iQuantity,v_iMethodOfPayment,(v_fAmount - v_fVatAmount),
									vRealFiscalMonth,vRealFiscalYear,vRealFiscalQuarter,vFiscalYear,vFiscalMonth,vFiscalQuarter);
              set v_iStatementID = last_insert_id() ;             
/*create audit/journal line for line just created*/                            
INSERT INTO debtor_statement_audit (ipkStatementAuditID,ifkDebtorTransactionType,ifkAccountID,sBatchNumber,iBatchItemNumber,iTransactionLineNumber,dTransactionDate,
									sTransactionDescription,sTarrifCode,sNappiCode,fTransactionAmount,dLineUpdateDate,fBalance,iLineCount,fReceiptTotal,fVatTotal,ifkFeeMedicalAidID,
									ifkFeeMedicalAidPlanID,sNextTM,sPatientFirtname,sPatientSurname,sPatientIDNumber,dPatientDOB,sMemberFirstname,sMemberSurname,sMemberIntials,sMemberIDNumber,
									dMemberDOB,sStructureCode,sDiagnosesCodes,ifkFeeingTypeID,fFilmUsage,ifkRadiologistID,ifkRadiographerID,ifkPrimaryDoctorID,ifkSecondaryDoctorID,iPatientAge,
									fVatAmount,ifkCapturedBy,bBalanceUpdatePending,iQty,ifkMethodOfPaymentID,fAmountExclVat,
									iRealFiscalMonth,iRealFiscalYear,iRealFiscalQuarter,iLineFiscalYear,iLineFiscalMonth,iLineFiscalQuarter)
								VALUES
								  (0,v_DebtorTransactionType,v_AccountID,v_BatchNumber,v_SuspendLineNum,v_iLineNumber,v_dLineDate,v_sDescription,v_sTarrifCode,
									v_sNappiCode,v_fAmount,current_timestamp,null,null,null,null,v_ifkFeeMedicalAidID,v_ifkFeeMedicalAidPlanID,v_sNextTM,
									v_sPatientFirtname,v_sPatientSurname,v_sPatientIDNumber,v_dPatientDOB,v_sMemberFirstname,v_sMemberSurname,v_sMemberIntials,v_sMemberIDNumber,v_dMemberDOB,v_sStructureCode,
									v_sDiagnosesCodes,v_ifkFeeingTypeID,v_fFilmUsage,v_ifkRadiologistID,v_ifkRadiographerID,v_ifkPrimaryDoctorID,v_ifkSecondaryDoctorID,v_iPatientAge,v_fVatAmount,v_CapturedBy,0,v_iQuantity,v_iMethodOfPayment,(v_fAmount - v_fVatAmount),
									vRealFiscalMonth,vRealFiscalYear,vRealFiscalQuarter,vFiscalYear,vFiscalMonth,vFiscalQuarter);
    set v_iStatementUidID  = last_insert_id() ;  
	if ((v_writeVatDetLine = 1) and (v_fVatAmount <> 0)) then begin
        /*Line has a vat amount to log*/
		CALL Debtor_WriteVatDet(v_AccountID, v_iStatementID, v_DebtorTransactionType,v_TaxType, v_dLineDate, 
						v_iLineNumber, v_sDescription, v_fAmount, v_fVatAmount, v_fVatPerc, 
                        v_bVatCreditNote);
   end; end if;
   if (v_bWriteOff = 1) then begin
     INSERT INTO debtor_writeoff (ipkWriteOffID,ifkDebtorTransactionType,sDescription,fAmount,dDateEntered,ifkCapturedby,ifkAccountID,fVatAmount,ifkStatementAuditID) VALUES
		(0,v_DebtorTransactionType,v_sDescription,-1 * vVatExclWaarde,current_timestamp,v_CapturedBy,v_AccountID,-1 * v_fVatAmount,v_iStatementUidID);
	 CALL DebtorEventCapture(v_AccountID, v_CapturedBy, vsLineType, v_sDescription,null);		
   end; end if;
   
     if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
                            
END$$

DELIMITER ;

