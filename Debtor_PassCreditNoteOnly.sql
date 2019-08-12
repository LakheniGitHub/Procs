use `promed`;
drop procedure if exists `Debtor_PassCreditNoteOnly`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_PassCreditNoteOnly`(in vAccID bigint,
						in  v_capturedby bigint(20),
						in v_adddate timestamp,
						in sReason mediumtext )
begin
  /*
/*
  A credit note is passed for the current invoice and a new invoice is created and all lines is re-added
  Nothing else is done. This is used when new fee lines are added to account that is flagged as a vat invoice account
  After the credit note is done, the new lines can be added.
*/
  
declare vbal decimal(18,2);
declare vvattot decimal(18,2);
declare vcreditnotedebtype bigint;
  
declare  vipkStatementEntryID bigint(20);
declare  vifkDebtorTransactionType bigint(20);
declare  vifkAccountID int(11);
declare  viLineNumber int(11);
declare  vdDateEntered timestamp ;
declare  vdLineDate timestamp ;
declare  vsDescription varchar(100);
declare  vsTarrifCode varchar(10);
declare  vsNappiCode varchar(10) ;
declare  vdUpdateDateTime timestamp ;
declare  vfAmount decimal(18,2) ;
declare  vfVatAmount decimal(18,2) ;
declare  vfVatPerc decimal(18,2) ;
declare  vsStructureCode varchar(10);
declare  vifkCapturedBy int(11) ;
declare  viQty int(11) ;
declare  vifkMethodOfPaymentID int(11);
declare  vfAmountExclVat decimal(18,2) ;
declare  vbEligPaidFlag int(11) ;
declare  viRealFiscalYear int(11) ;
declare  viRealFiscalMonth int(11) ;
declare  viRealFiscalQuarter int(11) ;
declare  viLineFiscalYear int(11) ;
declare  viLineFiscalMonth int(11) ;
declare  viLineFiscalQuarter int(11) ;
declare  vsBatchNumber varchar(10);
declare  viBatchNumber integer;
declare  vsReceiptCode varchar(10);
declare  vsPayer varchar(20);
declare  viReceiptID bigint;
declare  viTaxType bigint;
declare vbMoneyMovement smallint;

declare v_suspendid bigint;  

declare  v_accountid bigint(20) ; 

declare v_ilinenumber int(11);
declare vslinetype varchar(10);

declare v_bvatcreditnote smallint;
declare v_bdebitaccount smallint;
declare v_bvatcharge smallint;
declare v_snexttm char(1);

declare v_ifkfeemedicalaidid bigint;
declare v_ifkfeemedicalaidplanid bigint;
declare v_spatientfirtname varchar(45);
declare v_spatientsurname varchar(45);
declare v_spatientidnumber varchar(13);
declare v_dpatientdob date;
declare v_smemberfirstname varchar(45);
declare v_smembersurname varchar(45);
declare v_smemberintials varchar(10);
declare v_smemberidnumber varchar(13);
declare v_dmemberdob date;
declare v_sstructurecode varchar(10);
declare v_sdiagnosescodes varchar(80);
declare v_ifkfeeingtypeid bigint;
declare v_ffilmusage integer;
declare v_ifkradiologistid bigint;
declare v_ifkradiographerid bigint;
declare v_ifkprimarydoctorid bigint;
declare v_ifksecondarydoctorid bigint;
declare v_ipatientage integer;
declare v_ipatientdob date;
declare v_bwriteoff integer;
declare v_bmoneymovement integer;

declare vorig_famount decimal(18,2) ;
declare vorig_qty integer;
declare vorig_fvatamount decimal(18,2) ;

declare vvatexclwaarde decimal(18,2) ;
declare vaudit_famount decimal(18,2) ;
declare vaudit_qty integer;
declare vaudit_fvatamount decimal(18,2) ;
declare v_srcbalance decimal(18,2);
declare v_istatementuidid bigint;
  declare vfiscalyear integer;
  declare vfiscalmonth  integer;
  declare vfiscalquarter  integer;

  declare vrunfiscalyear integer;
  declare vrunfiscalmonth  integer;
  declare vrunfiscalquarter  integer;  
  
  declare vorigdate timestamp;
  declare vpracid bigint;
  declare vaccessionid  bigint;
  declare videbtoraccountinvoiceid bigint;

  declare vsiteid bigint;
  declare vbranchid bigint;
declare v_writevatdetline smallint;
declare vinvnum varchar(15);


declare done boolean default 0;
 declare MSG varchar(128);
 declare accountexportcurs cursor for select ipkStatementEntryID,
  ifkDebtorTransactionType,
  ifkAccountID,
  iLineNumber,
  dDateEntered,
  dLineDate,
  sDescription,
  sTarrifCode,
  sNappiCode,
  dUpdateDateTime,
  fAmount,
  fVatAmount,
  fVatPerc,
  sStructureCode,
  ifkCapturedBy,
  iQty,
  ifkMethodOfPaymentID,
  fAmountExclVat,
  bEligPaidFlag,
  iRealFiscalYear,
  iRealFiscalMonth,
  iRealFiscalQuarter,
  iLineFiscalYear,
  iLineFiscalMonth,
  iLineFiscalQuarter
  from tmpresult;
                                        
 declare continue handler for sqlstate '02000' set done = 1;          

 
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[dsle]:',MSG),1,128);   	
		rollback;
    set @g_transaction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  set autocommit = 0;
   if ((@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
     start transaction;  
     set @g_transaction_started = 1;
   end; else begin
    set @g_transaction_started = @g_transaction_started + 1;
   end; end if;
 /*Build Current line list*/
   drop temporary table if exists tmpresult; 
   
   
   create temporary table if not exists tmpresult engine=memory  as  (select ds.*
																		from debtor_statements ds
																		where ds.ifkAccountID = vaccid );

/*Pull account related info for audit table*/   

   set v_accountid = vaccid;
   select ifnull(MAX(iLineNumber), 0) into v_ilinenumber from debtor_statements where ifkAccountID = v_accountid;
   set v_ilinenumber = v_ilinenumber + 1;   
   select fBalance,fVatTotal into vbal,vvattot from accounts where ipkAccountID = vaccid;

   	select ipkDebtorTransactionType into vcreditnotedebtype from debtor_transaction_types where sTransactionTypeCode = 'CRDNOTE';

select da.iActiveFiscalYear,da.iActiveFiscalMonth,da.iActiveFiscalQuarter,da.ifkDebtorAccountInvoiceID, dai.sInvoiceNumber 
      into  vrunfiscalyear,vrunfiscalmonth,vrunfiscalquarter,videbtoraccountinvoiceid ,vinvnum
      from debtor_additional da,debtor_account_invoices dai where da.ifkAccountID = v_accountid and da.ifkDebtorAccountInvoiceID = dai.ipkDebtorAccountInvoiceID;
	  
select ipkAccessionID into vaccessionid from account_accessions where ifkAccountID = v_accountid and bActive = 1 and bDeleted = 0 order by ipkAccessionID limit 1;
SELECT ifkRadiographerOperatorID,ifkRadiologistOperatorID into v_ifkradiographerid, v_ifkradiologistid  FROM visit where ifkAccountID = v_accountid and ifkAccessionID = vaccessionid;

select a.ifkFeeMedicalAidID,a.ifkFeeMedicalAidPlanID,p.sName,p.sSurname,p.sIDNumber,p.dDateOfBirth,m.sName,m.sSurname,m.sInitials,m.sIDNumber,
		m.dMemberDateOfBirth ,a.ifkFeeingTypeID,a.ifkPrimaryReferringDoctorID,a.ifkSecondaryReferringDoctorID,date(p.dDateOfBirth),a.fBalance
   into v_ifkfeemedicalaidid,v_ifkfeemedicalaidplanid,v_spatientfirtname,v_spatientsurname,v_spatientidnumber,v_dpatientdob,v_smemberfirstname,v_smembersurname,v_smemberintials,
		v_smemberidnumber,v_dmemberdob,v_ifkfeeingtypeid,v_ifkprimarydoctorid,v_ifksecondarydoctorid,v_ipatientdob,v_srcbalance
  from accounts a, patients p, members m
  where a.ifkPatientID = p.ipkPatientID
  and m.ipkMemberID = a.ifkMemberID
  and a.ipkAccountID = v_accountid;
  
  set v_ipatientage = TIMESTAMPDIFF(YEAR, v_ipatientdob, CURDATE());
  
/*select group_concat(i.sICD10Code separator  ',') into v_sdiagnosescodes from debtor_statement_icd10 d,icd_10 i
where ifkaccountID = v_accountid
and iStatementLineNumber = v_ilinenumber 
and i.ipkICD10ID = d.ifkICD10ID
order by iLineNumber;
*/

set v_snexttm  = '';
  set vvatexclwaarde = (vbal -  vvattot);
   
   select a.ifkSiteID,s.ifkPracticeInfoID,a.ifkBranchID into vsiteid,vpracid,vbranchid  from accounts a,sites s where a.ipkAccountID = v_accountid and a.ifkSiteID  = s.ipkSiteID;
	
    /*cancel current invoice and create new one*/  
  	set done = 0;
    open accountexportcurs;                
	get_accountexport_cursor: loop
			fetch accountexportcurs into vipkStatementEntryID,
										  vifkDebtorTransactionType,
										  vifkAccountID,
										  viLineNumber,
										  vdDateEntered,
										  vdLineDate,
										  vsDescription,
										  vsTarrifCode,
										  vsNappiCode,
										  vdUpdateDateTime,
										  vfAmount,
										  vfVatAmount,
										  vfVatPerc,
										  vsStructureCode,
										  vifkCapturedBy,
										  viQty,
										  vifkMethodOfPaymentID,
										  vfAmountExclVat,
										  vbEligPaidFlag,
										  viRealFiscalYear,
										  viRealFiscalMonth,
										  viRealFiscalQuarter,
										  viLineFiscalYear,
										  viLineFiscalMonth,
										  viLineFiscalQuarter;
			
			if done = 1 then begin
			   leave get_accountexport_cursor;
			end; end if;	
			set vfAmount = -1 * vfAmount;
			set vfVatAmount = -1 * vfVatAmount;
			set vfAmountExclVat =  -1 * vfAmountExclVat;
			
    call debtorpracticefiscalinfofordate(vpracid,vdLineDate,viLineFiscalYear,viLineFiscalQuarter,viLineFiscalMonth); 
	call debtorpracticefiscalinfofordate(vpracid,date(v_adddate),viRealFiscalYear,viRealFiscalQuarter,viRealFiscalMonth); 
			
			
			SELECT da.sBatchNumber,da.iBatchItemNumber,da.ifkTaxType into  vsBatchNumber,viBatchNumber,viTaxType FROM debtor_statement_audit da 
					where da.ifkAccountID = vaccid 
					and da.iTransactionLineNumber = viLineNumber 
					and da.ifkDebtorTransactionType = vifkDebtorTransactionType 
					order by da.ipkStatementAuditID desc limit 1;
					
			 select ds.sPayer,ds.sReceiptCode,ds.ifkReceiptID into vsPayer,vsReceiptCode,viReceiptID  
				from debtor_suspense ds 
				where ds.sBatchNumber = vsBatchNumber 
				and ds.iBatchItemNumber = viBatchNumber 
				and ds.ifkAccountID = vaccid;					
			
				select group_concat(i.sICD10Code separator  ',') into v_sdiagnosescodes from debtor_statement_icd10 d,icd_10 i
				where ifkaccountID = v_accountid
				and iStatementLineNumber = viLineNumber 
				and i.ipkICD10ID = d.ifkICD10ID
				order by iLineNumber;

				select sTransactionTypeCode,bVatCharge,bDebitAccount,bVatCreditNote,bMoneyMovement,bWriteOff 
					into vslinetype,v_bvatcharge,v_bdebitaccount,v_bvatcreditnote,vbMoneyMovement,v_bwriteoff 
					from debtor_transaction_types
					where ipkDebtorTransactionType = vifkDebtorTransactionType;	

				case vslinetype
					when  'FEEADJ' then
						set v_snexttm = 'N';
						/*set v_writevatdetline = 1;*/
					when 'WRTOFF' then
						set v_snexttm = 'S';
						
					when 'BADWOFF' then
						set v_snexttm = 'N';
						
					when 'DISCNT' then
						set v_snexttm = 'N';
					when 'TRNSFR' then
						set v_snexttm = 'N';
					when 'REFUND' then
						set v_snexttm = 'S';
						
					when 'CHEQUES' then
						set v_snexttm = 'F';
					when 'NOTE' then
						set v_snexttm = 'S';
					else
						set v_snexttm = 'F';
				 end case;
 
				insert into debtor_statement_audit (ipkStatementAuditID,ifkDebtorTransactionType,ifkaccountID,sBatchNumber,iBatchItemNumber,iTransactionLineNumber,dTransactionDate,
						sTransactionDescription,sTarrifCode,sNappiCode,fTransactionAmount,dLineUpdateDate,fBalance,iLineCount,fReceiptTotal,fVatTotal,ifkFeeMedicalAidID,
						ifkFeeMedicalAidPlanID,sNextTM,sPatientFirtname,sPatientSurname,sPatientIDNumber,dPatientDOB,sMemberFirstname,sMemberSurname,sMemberIntials,sMemberIDNumber,
						dMemberDOB,sStructureCode,sDiagnosesCodes,ifkFeeingTypeID,fFilmUsage,ifkRadiologistID,ifkRadiographerID,ifkPrimaryDoctorID,ifkSecondaryDoctorID,iPatientAge,
						fVATAmount,ifkCapturedBy,bBalanceUpdatePending,iQty,ifkMethodOfPaymentID,fAmountExclVat,
						iRealFiscalMonth,iRealFiscalYear,iRealFiscalQuarter,iLineFiscalYear,iLineFiscalMonth,iLineFiscalQuarter,dDateEntered,iRunFiscalYear,iRunFiscalMonth,iRunFiscalQuarter,
						ifkDebtorAccountInvoiceID,sReceiptCode,ifkTaxType)
					values
					  (0,vifkDebtorTransactionType,vifkAccountID,vsBatchNumber,viBatchNumber,viLineNumber,vdLineDate,vsDescription,vsTarrifCode,
						vsNappiCode,vfAmount,v_adddate,null,null,null,null,v_ifkfeemedicalaidid,v_ifkfeemedicalaidplanid,v_snexttm,
						v_spatientfirtname,v_spatientsurname,v_spatientidnumber,v_dpatientdob,v_smemberfirstname,v_smembersurname,v_smemberintials,v_smemberidnumber,v_dmemberdob,v_sstructurecode,
						v_sdiagnosescodes,v_ifkfeeingtypeid,v_ffilmusage,v_ifkradiologistid,v_ifkradiographerid,v_ifkprimarydoctorid,v_ifksecondarydoctorid,v_ipatientage,vfVatAmount,
						v_capturedby,0,
						viQty,vifkMethodOfPaymentID,(vfAmount - vfVatAmount),
						viRealFiscalMonth,viRealFiscalYear,viRealFiscalQuarter,viLineFiscalYear,viLineFiscalMonth,viLineFiscalQuarter,v_adddate,
						vrunfiscalyear,vrunfiscalmonth,vrunfiscalquarter,
						videbtoraccountinvoiceid,vsReceiptCode,viTaxType);
						
			if (vfVatAmount <> 0) then begin
				/*LINE has a vat amount to log*/
				call debtor_writevatdet(vifkAccountID, vipkStatementEntryID, vifkDebtorTransactionType,viTaxType, vdLineDate, 
								viLineNumber, vsDescription, vfAmount, vfVatAmount, vfVatPerc, v_bvatcreditnote,v_adddate);
		    end; end if;
   
			set done = 0;
	end loop get_accountexport_cursor;
    close accountexportcurs;
    call debtorpracticefiscalinfofordate(vpracid,v_adddate,viLineFiscalYear,viLineFiscalQuarter,viLineFiscalMonth); 
	call debtorpracticefiscalinfofordate(vpracid,date(v_adddate),viRealFiscalYear,viRealFiscalQuarter,viRealFiscalMonth); 
	set vsDescription = concat('CREDIT NOTE FOR ',vinvnum);
	
	/*Create the Credit Note line in audit table*/
insert into debtor_statement_audit (ipkStatementAuditID,ifkDebtorTransactionType,ifkaccountID,sBatchNumber,iBatchItemNumber,iTransactionLineNumber,dTransactionDate,
									sTransactionDescription,sTarrifCode,sNappiCode,fTransactionAmount,dLineUpdateDate,fBalance,iLineCount,fReceiptTotal,fVatTotal,ifkFeeMedicalAidID,
									ifkFeeMedicalAidPlanID,sNextTM,sPatientFirtname,sPatientSurname,sPatientIDNumber,dPatientDOB,sMemberFirstname,sMemberSurname,sMemberIntials,sMemberIDNumber,
									dMemberDOB,sStructureCode,sDiagnosesCodes,ifkFeeingTypeID,fFilmUsage,ifkRadiologistID,ifkRadiographerID,ifkPrimaryDoctorID,ifkSecondaryDoctorID,iPatientAge,
									fVATAmount,ifkCapturedBy,bBalanceUpdatePending,iQty,ifkMethodOfPaymentID,fAmountExclVat,
									iRealFiscalMonth,iRealFiscalYear,iRealFiscalQuarter,iLineFiscalYear,iLineFiscalMonth,iLineFiscalQuarter,dDateEntered,iRunFiscalYear,iRunFiscalMonth,iRunFiscalQuarter,
									ifkDebtorAccountInvoiceID,sReceiptCode,ifkTaxType)
								values
								  (0,vcreditnotedebtype,v_accountid,'',0,v_ilinenumber,v_adddate,vsDescription,'',
									'',0,v_adddate,0,null,null,0,v_ifkfeemedicalaidid,v_ifkfeemedicalaidplanid,v_snexttm,
									v_spatientfirtname,v_spatientsurname,v_spatientidnumber,v_dpatientdob,v_smemberfirstname,v_smembersurname,v_smemberintials,v_smemberidnumber,v_dmemberdob,v_sstructurecode,
									'',v_ifkfeeingtypeid,v_ffilmusage,v_ifkradiologistid,v_ifkradiographerid,v_ifkprimarydoctorid,v_ifksecondarydoctorid,v_ipatientage,0,v_capturedby,1,
									0,null,0,
									viRealFiscalMonth,viRealFiscalYear,viRealFiscalQuarter,viLineFiscalYear,viLineFiscalMonth,viLineFiscalQuarter,v_adddate,vrunfiscalyear,vrunfiscalmonth,vrunfiscalquarter,
									videbtoraccountinvoiceid,'',viTaxType);
	

	
	call DebtorInvoiceCancel(v_accountid,sReason,v_capturedby);
	
	select iActiveFiscalYear,iActiveFiscalMonth,iActiveFiscalQuarter,ifkDebtorAccountInvoiceID into  vrunfiscalyear,vrunfiscalmonth,vrunfiscalquarter,videbtoraccountinvoiceid from debtor_additional where ifkAccountID = v_accountid;
	
	set done = 0;
    open accountexportcurs;                
	get_accountexport_cursor: loop
			fetch accountexportcurs into vipkStatementEntryID,
										  vifkDebtorTransactionType,
										  vifkAccountID,
										  viLineNumber,
										  vdDateEntered,
										  vdLineDate,
										  vsDescription,
										  vsTarrifCode,
										  vsNappiCode,
										  vdUpdateDateTime,
										  vfAmount,
										  vfVatAmount,
										  vfVatPerc,
										  vsStructureCode,
										  vifkCapturedBy,
										  viQty,
										  vifkMethodOfPaymentID,
										  vfAmountExclVat,
										  vbEligPaidFlag,
										  viRealFiscalYear,
										  viRealFiscalMonth,
										  viRealFiscalQuarter,
										  viLineFiscalYear,
										  viLineFiscalMonth,
										  viLineFiscalQuarter;
			
			if done = 1 then begin
			   leave get_accountexport_cursor;
			end; end if;	
			
			SELECT da.sBatchNumber,da.iBatchItemNumber,da.ifkTaxType into  vsBatchNumber,viBatchNumber,viTaxType FROM debtor_statement_audit da 
					where da.ifkAccountID = vaccid 
					and da.iTransactionLineNumber = viLineNumber 
					and da.ifkDebtorTransactionType = vifkDebtorTransactionType 
					order by da.ipkStatementAuditID desc limit 1;
					
			 select ds.sPayer,ds.sReceiptCode,ds.ifkReceiptID into vsPayer,vsReceiptCode,viReceiptID  
				from debtor_suspense ds 
				where ds.sBatchNumber = vsBatchNumber 
				and ds.iBatchItemNumber = viBatchNumber 
				and ds.ifkAccountID = vaccid;					
			
				select group_concat(i.sICD10Code separator  ',') into v_sdiagnosescodes from debtor_statement_icd10 d,icd_10 i
				where ifkaccountID = v_accountid
				and iStatementLineNumber = viLineNumber 
				and i.ipkICD10ID = d.ifkICD10ID
				order by iLineNumber;

				select sTransactionTypeCode,bVatCharge,bDebitAccount,bVatCreditNote,bMoneyMovement,bWriteOff 
					into vslinetype,v_bvatcharge,v_bdebitaccount,v_bvatcreditnote,vbMoneyMovement,v_bwriteoff 
					from debtor_transaction_types
					where ipkDebtorTransactionType = vifkDebtorTransactionType;	

				case vslinetype
					when  'FEEADJ' then
						set v_snexttm = 'N';
						/*set v_writevatdetline = 1;*/
					when 'WRTOFF' then
						set v_snexttm = 'S';
						
					when 'BADWOFF' then
						set v_snexttm = 'N';
						
					when 'DISCNT' then
						set v_snexttm = 'N';
					when 'TRNSFR' then
						set v_snexttm = 'N';
					when 'REFUND' then
						set v_snexttm = 'S';
						
					when 'CHEQUES' then
						set v_snexttm = 'F';
					when 'NOTE' then
						set v_snexttm = 'S';
					else
						set v_snexttm = 'F';
				 end case;
 
				insert into debtor_statement_audit (ipkStatementAuditID,ifkDebtorTransactionType,ifkaccountID,sBatchNumber,iBatchItemNumber,iTransactionLineNumber,dTransactionDate,
						sTransactionDescription,sTarrifCode,sNappiCode,fTransactionAmount,dLineUpdateDate,fBalance,iLineCount,fReceiptTotal,fVatTotal,ifkFeeMedicalAidID,
						ifkFeeMedicalAidPlanID,sNextTM,sPatientFirtname,sPatientSurname,sPatientIDNumber,dPatientDOB,sMemberFirstname,sMemberSurname,sMemberIntials,sMemberIDNumber,
						dMemberDOB,sStructureCode,sDiagnosesCodes,ifkFeeingTypeID,fFilmUsage,ifkRadiologistID,ifkRadiographerID,ifkPrimaryDoctorID,ifkSecondaryDoctorID,iPatientAge,
						fVATAmount,ifkCapturedBy,bBalanceUpdatePending,iQty,ifkMethodOfPaymentID,fAmountExclVat,
						iRealFiscalMonth,iRealFiscalYear,iRealFiscalQuarter,iLineFiscalYear,iLineFiscalMonth,iLineFiscalQuarter,dDateEntered,iRunFiscalYear,iRunFiscalMonth,iRunFiscalQuarter,
						ifkDebtorAccountInvoiceID,sReceiptCode,ifkTaxType)
					values
					  (0,vifkDebtorTransactionType,vifkAccountID,vsBatchNumber,viBatchNumber,viLineNumber,vdLineDate,vsDescription,vsTarrifCode,
						vsNappiCode,vfAmount,v_adddate,null,null,null,null,v_ifkfeemedicalaidid,v_ifkfeemedicalaidplanid,v_snexttm,
						v_spatientfirtname,v_spatientsurname,v_spatientidnumber,v_dpatientdob,v_smemberfirstname,v_smembersurname,v_smemberintials,v_smemberidnumber,v_dmemberdob,v_sstructurecode,
						v_sdiagnosescodes,v_ifkfeeingtypeid,v_ffilmusage,v_ifkradiologistid,v_ifkradiographerid,v_ifkprimarydoctorid,v_ifksecondarydoctorid,v_ipatientage,vfVatAmount,
						v_capturedby,0,
						viQty,vifkMethodOfPaymentID,(vfAmount - vfVatAmount),
						viRealFiscalMonth,viRealFiscalYear,viRealFiscalQuarter,viLineFiscalYear,viLineFiscalMonth,viLineFiscalQuarter,v_adddate,
						vrunfiscalyear,vrunfiscalmonth,vrunfiscalquarter,
						videbtoraccountinvoiceid,vsReceiptCode,viTaxType);
		    if (vfVatAmount <> 0) then begin
				/*LINE has a vat amount to log*/
				call debtor_writevatdet(vifkAccountID, vipkStatementEntryID, vifkDebtorTransactionType,viTaxType, vdLineDate, 
								viLineNumber, vsDescription, vfAmount, vfVatAmount, vfVatPerc, v_bvatcreditnote,v_adddate);
		    end; end if;
			
									
			set done = 0;
	end loop get_accountexport_cursor;
    close accountexportcurs;
	
	
     call DebtorUpdateVisitTotals(vifkAccountID);
     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
end$$

delimiter ;