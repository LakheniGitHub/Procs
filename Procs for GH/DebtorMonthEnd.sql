USE `promed`;
DROP procedure IF EXISTS `DebtorMonthEnd`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DebtorMonthEnd`(in vdate date)
BEGIN
  /*
    3 Des 2018
    Johannes
    Runs the month end for all practices for the date given. (gets sums for running also)
    then sets practices currentmonth to the new month , no transactions dates then to be allowed backdated
    past current month
  */
  
  declare vStart timestamp;
  declare vNextACtiveMonth date;
  declare vEnd timestamp;
  declare vLastM date;
  declare vPrevM date;
  declare vYear integer;
  declare vMonth integer;
  declare vPracID bigint;
  declare vExist integer;
    declare vFiscalYear integer;
  declare vFiscalMonth  integer;
  declare vFiscalQuarter  integer;
  
  declare vAmount_Nrm decimal(18,2);
  declare vVatAmount_Nrm decimal(18,2);
  declare vVatExclAmount_Nrm decimal(18,2);  declare vVatExclAmount_Nrm_Jrnl decimal(18,2);  declare vVatExclAmount_Nrm_Pay decimal(18,2);

  declare vAmount_Run decimal(18,2);
  declare vVatAmount_Run decimal(18,2);
  declare vVatExclAmount_Run decimal(18,2);  declare vVatExclAmount_Run_Jrnl decimal(18,2);  declare vVatExclAmount_Run_Pay decimal(18,2);
  
  declare vYtd_Run_Jrnl decimal(18,2);  declare vYtd_Run_Pay decimal(18,2);
  declare vYtd_Nrm_Jrnl decimal(18,2);  declare vYtd_Nrm_Pay decimal(18,2);    declare vYtd_Nrm_Tot decimal(18,2);  declare vYtd_Run_Tot decimal(18,2);
  
   DECLARE done BOOLEAN DEFAULT 0;
   declare msg VARCHAR(128);
   declare tmpmsg VARCHAR(128);
   
  DECLARE PracticeCursor CURSOR FOR SELECT ipkPracticeInfoID FROM practice_info;
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;  
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[DME]:',msg),1,128);   	
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
 
  set vEnd = last_day(vdate);
  set vLastM = last_day(vdate);
  set vPrevM  =  date_sub(vLastM,interval 1 month);
  set vPrevM  =  last_day(vPrevM);
  
  set vEnd = TIMESTAMPADD(HOUR,23,vEnd);
  set vEnd = TIMESTAMPADD(MINUTE,59,vEnd);
  set vEnd = TIMESTAMPADD(SECOND,59,vEnd);
  
  set vYear = year(vdate);
  set vMonth = month(vdate);
  set vStart = concat(vYear ,'-',vMonth,'-01');
  set vNextACtiveMonth = TIMESTAMPADD(MONTH,1,vStart);
   
  OPEN PracticeCursor;   
  
    get_Practice_Cursor: LOOP
			FETCH PracticeCursor INTO vPracID;
			IF done = 1 THEN begin
			   LEAVE get_Practice_Cursor;
			end; END IF;	
            set vExist =  0;
            select count(ipkMonthEndID) into vExist from  debtor_monthend_totals where dRunMonth = vLastM and ifkPracticeInfoID = vPracID;
            if (vExist >= 1) then begin
                set tmpmsg =   concat('Month end already ran for ',vLastM,' and prtactice ',vPracID);      
				signal sqlstate '45000'
				SET MESSAGE_TEXT = tmpmsg;
            end; end if;

            call DebtorPracticeFiscalInfoForDate(vPracID,vLastM,vFiscalYear,vFiscalQuarter,vFiscalMonth);  
            
            
			INSERT INTO debtor_monthend_totals ( ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID, fAmount, fVatAmount,fAmountExclVat ,
									iFiscalYear,iFiscalQuarter,iFiscalMonth,dRunMonth)
								
                            (
                            select   ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID,sum(fAmount),sum(fVatAmount),sum(fAmountExclVat), vFiscalYear,vFiscalQuarter,vFiscalMonth,vLastM
                              from debtor_dayend_totals where dDate >= vStart and dDate <= vEnd and ifkPracticeInfoID = vPracID
                              group by ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID
                            );
                            			INSERT INTO debtor_monthend_additional_totals (ipkMonthendAddTotalsID,ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkMedicalAidID,ifkPrimaryDoctorID,			                                              ifkSecondaryDoctorID,ifkAgeID,ifkDebtorTransactionType,ifkMethodOfPaymentID,fAmount,fVatAmount,fAmountExclVat,														  iFiscalYear,iFiscalMonth,iFiscalQuarter,dRunMonth)																						(									SELECT 0,s.ifkPracticeInfoID,s.ipkSiteID,a.ifkBranchID,dsa.ifkFeeMedicalAidID,a.ifkPrimaryReferringDoctorID,										   a.ifkSecondaryReferringDoctorID,da.ifkAgeID,dsa.ifkDebtorTransactionType,dsa.ifkMethodOfPaymentID,sum(dsa.fTransactionAmount),										   sum(dsa.fVatAmount),sum(dsa.fAmountExclVat),vFiscalYear,vFiscalMonth,vFiscalQuarter,vLastM									FROM debtor_statement_audit dsa,accounts a, sites s,debtor_additional da									where a.ipkAccountID = dsa.ifkAccountID									and da.ifkAccountID = a.ipkAccountID									and a.ifkSiteID = s.ipkSiteID									and dsa.dDateEntered >= vStart 									and dsa.dDateEntered <= vEnd 									and s.ifkPracticeInfoID = vPracID									group by s.ifkPracticeInfoID,s.ipkSiteID,a.ifkBranchID,dsa.ifkFeeMedicalAidID,a.ifkPrimaryReferringDoctorID,a.ifkSecondaryReferringDoctorID,									        dsa.ifkDebtorTransactionType,dsa.ifkMethodOfPaymentID                            );											
			INSERT INTO debtor_monthend_running_totals ( ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID, fAmount, fVatAmount,fAmountExclVat ,
									iFiscalYear,iFiscalQuarter,iFiscalMonth,dRunMonth)
								
                            (
                            select   ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID,sum(fAmount),sum(fVatAmount),sum(fAmountExclVat), vFiscalYear,vFiscalQuarter,vFiscalMonth,vLastM
                              from debtor_running_totals where dLineDate >= vStart and dLineDate <= vEnd and ifkPracticeInfoID = vPracID
                              group by ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkDebtorTransactionType,ifkMethodOfPaymentID
                            );										INSERT INTO debtor_monthend_additional_running_totals (ipkMonthendAddRunningTotalsID,ifkPracticeInfoID,ifkSiteID,ifkBranchID,ifkMedicalAidID,ifkPrimaryDoctorID,			                                              ifkSecondaryDoctorID,ifkAgeID,ifkDebtorTransactionType,ifkMethodOfPaymentID,fAmount,fVatAmount,fAmountExclVat,														  iFiscalYear,iFiscalMonth,iFiscalQuarter,dRunMonth)																						(									SELECT 0,s.ifkPracticeInfoID,s.ipkSiteID,a.ifkBranchID,dsa.ifkFeeMedicalAidID,a.ifkPrimaryReferringDoctorID,										   a.ifkSecondaryReferringDoctorID,da.ifkAgeID,dsa.ifkDebtorTransactionType,dsa.ifkMethodOfPaymentID,sum(dsa.fTransactionAmount),										   sum(dsa.fVatAmount),sum(dsa.fAmountExclVat),vFiscalYear,vFiscalMonth,vFiscalQuarter,vLastM									FROM debtor_statement_audit dsa,accounts a, sites s,debtor_additional da									where a.ipkAccountID = dsa.ifkAccountID									and da.ifkAccountID = a.ipkAccountID									and a.ifkSiteID = s.ipkSiteID									and dsa.dTransactionDate >= vStart 									and dsa.dTransactionDate <= vEnd 									and s.ifkPracticeInfoID = vPracID									group by s.ifkPracticeInfoID,s.ipkSiteID,a.ifkBranchID,dsa.ifkFeeMedicalAidID,a.ifkPrimaryReferringDoctorID,a.ifkSecondaryReferringDoctorID,									        dsa.ifkDebtorTransactionType,dsa.ifkMethodOfPaymentID                            );							
                                                        
            SELECT ifnull(sum(famount),0),ifnull(sum(fvatamount),0),ifnull(sum(fAmountExclVat),0) into vAmount_Nrm,vVatAmount_Nrm,vVatExclAmount_Nrm FROM debtor_monthend_totals where dRunMonth = vLastM and ifkPracticeInfoID = vPracID;
			
			SELECT ifnull(sum(famount),0),ifnull(sum(fvatamount),0),ifnull(sum(fAmountExclVat),0) into vAmount_Run,vVatAmount_Run,vVatExclAmount_Run FROM debtor_monthend_running_totals where dRunMonth = vLastM and ifkPracticeInfoID = vPracID;									SELECT ifnull(sum(fAmountExclVat),0) into vVatExclAmount_Nrm_Jrnl FROM debtor_transaction_types dt,debtor_monthend_totals de left join methods_of_payment mp on mp.ipkMethodofPaymentID = de.ifkMethodOfPaymentID						where de.ifkDebtorTransactionType = dt.ipkDebtorTransactionType and dt.bMoneyMovement = 0 and dRunMonth = vLastM and ifkPracticeInfoID = vPracID;						SELECT ifnull(sum(fAmountExclVat),0) into vVatExclAmount_Nrm_Pay FROM debtor_transaction_types dt,debtor_monthend_totals de left join methods_of_payment mp on mp.ipkMethodofPaymentID = de.ifkMethodOfPaymentID						where de.ifkDebtorTransactionType = dt.ipkDebtorTransactionType and dt.bMoneyMovement = 1 and dRunMonth = vLastM and ifkPracticeInfoID = vPracID;			SELECT ifnull(sum(fAmountExclVat),0) into vVatExclAmount_Run_Jrnl FROM debtor_transaction_types dt,debtor_monthend_running_totals de left join methods_of_payment mp on mp.ipkMethodofPaymentID = de.ifkMethodOfPaymentID						where de.ifkDebtorTransactionType = dt.ipkDebtorTransactionType and dt.bMoneyMovement = 0 and dRunMonth = vLastM and ifkPracticeInfoID = vPracID;						SELECT ifnull(sum(fAmountExclVat),0) into vVatExclAmount_Run_Pay FROM debtor_transaction_types dt,debtor_monthend_running_totals de left join methods_of_payment mp on mp.ipkMethodofPaymentID = de.ifkMethodOfPaymentID						where de.ifkDebtorTransactionType = dt.ipkDebtorTransactionType and dt.bMoneyMovement = 1 and dRunMonth = vLastM and ifkPracticeInfoID = vPracID;						
			
            select ifnull(fYearToDate_Jrnl_Run,0),ifnull(fYearToDate_Jrnl_Nrm,0),ifnull(fYearToDate_Paymnt_Run,0),ifnull(fYearToDate_Paymnt_Nrm,0) 								into vYtd_Run_Jrnl,vYtd_Nrm_Jrnl,vYtd_Run_Pay,vYtd_Nrm_Pay from debtor_month_control_totals where dRunMonth = vPrevM and ifkPracticeInfoID = vPracID;
						set vYtd_Run_Jrnl = ifnull(vYtd_Run_Jrnl,0);			set vYtd_Nrm_Jrnl = ifnull(vYtd_Nrm_Jrnl,0);			set vYtd_Run_Pay = ifnull(vYtd_Run_Pay,0);			set vYtd_Nrm_Pay = ifnull(vYtd_Nrm_Pay,0);						set vYtd_Nrm_Tot = (vYtd_Nrm_Jrnl + vVatExclAmount_Nrm_Jrnl) + (vYtd_Nrm_Pay + vVatExclAmount_Nrm_Pay);			set vYtd_Run_Tot = (vYtd_Run_Jrnl + vVatExclAmount_Run_Jrnl) + (vYtd_Run_Pay + vVatExclAmount_Run_Pay);
            INSERT INTO debtor_month_control_totals (ipkMonthControlTotalID, dRunMonth,iFiscalYear,iFiscalMonth,iFiscalQuarter,dDateEntered,ifkPracticeInfoID,
													fAmount_Nrm,fVatAmount_Nrm,fAmountExclVat_Nrm,fYearToDate_Jrnl_Nrm,fAmount_Run,fVatAmount_Run,fAmountExclVat_Run,fYearToDate_Jrnl_Run,fYearToDate_Paymnt_Run,fYearToDate_Paymnt_Nrm,fYearToDate_Nrm_Tot,fYearToDate_Run_Tot)
												VALUES
											(0,vLastM,vFiscalYear,vFiscalMonth,vFiscalQuarter,CURRENT_TIMESTAMP,vPracID,vAmount_Nrm,vVatAmount_Nrm,vVatExclAmount_Nrm,(vYtd_Nrm_Jrnl + vVatExclAmount_Nrm_Jrnl),
											vAmount_Run,vVatAmount_Run,vVatExclAmount_Run,(vYtd_Run_Jrnl + vVatExclAmount_Run_Jrnl),(vYtd_Run_Pay + vVatExclAmount_Run_Pay),(vYtd_Nrm_Pay + vVatExclAmount_Nrm_Pay),vYtd_Nrm_Tot,vYtd_Run_Tot);
									
            update debtor_practice_info set iActiveMonth = vNextACtiveMonth where ifkPracticeInfoID = vPracID;
			set done = 0;
	END LOOP get_Practice_Cursor;
    
  CLOSE PracticeCursor;  
  call DebtorRunAutoTasks(vStart,vEnd,'MONTHLY','JOBS');  call DebtorRunAutoTasks(vStart,vEnd,'MONTHLY','REPORT');
  
  if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
END$$

DELIMITER ;

