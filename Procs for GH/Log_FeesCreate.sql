use `promed`;
drop procedure if exists `Log_FeesCreate`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Log_FeesCreate` (in iaccountid bigint)
begin
	/* on success return 1 , else 0 */
    	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[lFC1]:',MSG),1,128);   	
			rollback;
    set @g_transAction_started = 0;
		signal sqlstate '45000' set message_text = MSG;
	 end;
      set autocommit = 0;
   if ((@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
     start transAction;  
     set @g_transAction_started = 1;
   end; else begin
    set @g_transAction_started = @g_transAction_started + 1;
   end; end if; 
   
insert into promed_logs.account_fees_change_log
(ipkAccountFeelogid,
F_ipkFeeID,
F_ifkAccountID,
F_ifkVisitID,
F_fUnitPRICE,
F_dLINEDate,
F_dDateEntered,
F_fPaidAmount,
F_iREFERENCE,
F_iFeeLINE,
F_iQuantity,
F_sSMCode,
F_iMINimum,
F_iMAXimum,
F_iStructureLINE,
F_iSequence,
F_fCost,
/*f_ifkDEPARTMENTid,*/
F_bPaidFlag,
F_iFeeLINEID,
F_sMCPIND,
F_sPromedInitials,
F_sStrucCode,
F_sType,
F_sTarrifCode,
F_bFEED,
F_sDescription,
F_sFunderReferenceNumber,
F_sSMFlag,
F_sMandatory,
F_sPCLoginName,
F_sPromedLoginName,
F_sPCHostName,
F_sPCWinDescription,
F_sPayDenyReason,
F_bCommentLINE,
F_fVatAmount,
A_ifkFeeMedicalAidID,
A_ifkFeeMedicalAidPlanID,
A_fFeeSpecialAmount,
A_fFeeFactor,
A_fBalance,
A_fVatTotal,
A_fReceiptTotal,
A_fPaidTotal,
A_iLINECount,
A_ifkMemberID,
A_ifkPatientID,
A_bAfterHours,
A_bVATInvoice,
A_bHospitalPatient,
A_bExported,
A_dDateEntered,
A_dDateExported,
A_dExamDate,
P_sTITLE,
P_sInitials,
P_sName,
P_ssurname,
P_sIDNumber,
P_dDateOfBirth,
P_iPDependantNo,
P_sUID,
P_ifkRelationID,
M_ifkMedicalAidID,
M_ifkMedicalAidPlanID,
M_dMemberDateOfBirth,
M_sMedicalAidClaim,
M_iDependants,
M_sTITLE,
M_sInitials,
M_sName,
M_sMedicalAidReference,
M_sIDNumber,
M_ssurname) select 0,f.ipkFeeID,
f.ifkAccountID,
f.ifkVisitID,
f.fUnitPRICE,
f.dLINEDate,
f.dDateEntered,
f.fPaidAmount,
f.iREFERENCE,
f.iFeeLINE,
f.iQuantity,
f.sSMCode,
f.iMINimum,
f.iMAXimum,
f.iStructureLINE,
f.iSequence,
f.fCost,
/*f.ifkDEPARTMENTid,*/
f.bPaidFlag,
f.iFeeLINEID,
f.sMCPIND,
f.sPromedInitials,
f.sStrucCode,
f.sType,
f.sTarrifCode,
f.bFEED,
f.sDescription,
f.sFunderReferenceNumber,
f.sSMFlag,
f.sMandatory,
f.sPCLoginName,
f.sPromedLoginName,
f.sPCHostName,
f.sPCWinDescription,
f.sPayDenyReason,
f.bCommentLINE,
f.fVatAmount,
a.ifkFeeMedicalAidID,
a.ifkFeeMedicalAidPlanID,
a.fFeeSpecialAmount,
a.fFeeFactor,
a.fBalance,
a.fVatTotal,
a.fReceiptTotal,
a.fPaidTotal,
a.iLINECount,
a.ifkMemberID,
a.ifkPatientID,
a.bAfterHours,
a.bVATInvoice,
a.bHospitalPatient,
a.bExported,
a.dDateEntered,
a.dDateExported,
a.dExamDate,
p.sTITLE,
p.sInitials,
p.sName,
p.ssurname,
p.sIDNumber,
p.dDateOfBirth,
p.iPDependantNo,
p.sUID,
p.ifkRelationID,
m.ifkMedicalAidID,
m.ifkMedicalAidPlanID,
m.dMemberDateOfBirth,
m.sMedicalAidClaim,
m.iDependants,
m.sTITLE,
m.sInitials,
m.sName,
m.sMedicalAidReference,
m.sIDNumber,
m.ssurname from fees f, accounts a, members m, patients p
where f.ifkAccountID = a.ipkAccountID and a.ifkMemberID = m.ipkMemberID and a.ifkPatientID = p.ipkPatientID
and a.ipkAccountID = iaccountid and f.bFEED = 1;

	if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
  
end$$

delimiter ;

