use `promed`;
drop procedure if exists `Debtor_ReportingDailyControlTotals`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyControlTotals`(in vday date, in vpracid bigint)
begin

   /*
     return the control totals for the day. NOTE some are runnin totals, thus might change per run
   */
   declare vprevrunmonth date;
   declare vytd decimal(18,2);
   declare vmtd decimal(18,2);
   declare vmtclosed decimal(18,2);
   declare vopenbal decimal(18,2);
   declare vclosebal decimal(18,2);
   
   declare vfeestoday decimal(18,2);
   declare vjournalstoday decimal(18,2);
   declare vreceiptstoday decimal(18,2);
   declare vsmallbalancetoday decimal(18,2);
   declare vbaddebttoday decimal(18,2);
   declare vwriteofftot decimal(18,2);
   declare vsuspensetot decimal(18,2);
   declare veraoutstandingtot decimal(18,2);
   
   declare vtranid bigint;
   declare vsmallbalid bigint;   
   
   declare vstartday date;
   declare vendday date;
   
   declare vy integer;
   declare vm integer;
   declare vd integer;
   
  
   set vprevrunmonth = date_sub(vday, interval 1 month);
   set vprevrunmonth = last_day(vprevrunmonth);
   
   set vy = year(vday);
   set vm = month(vday);
   set vd = day(vday);
   set vstartday = concat(vy,'-',vm,'-01');
   
   if (vd = 1) then begin
     /*is first day of month. thus just use last months ytd and add 0*/
     set vmtd = 0.0;
   end;  else begin
      
      set vendday = date_sub(vday,interval 1 day);
		select ifnull(sum(fAmount),0) into vmtd 
           from debtor_transAction_types dt,debtor_dayend_totals de 
			where de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType /*and dt.bMoneyMovement = 0*/ and ifkPracticeInfoID = vpracid
            and dDate >= vstartday and dDate <= vendday;
                        
   end; end if;
	select ifnull(sum(fAmount),0) into vmtclosed 
        from debtor_transAction_types dt,debtor_dayend_totals de 
	    where de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType /*and dt.bMoneyMovement = 0*/ and  ifkPracticeInfoID = vpracid
        and dDate >= vstartday and dDate <= vday;   
   
  select ifnull(fYearToDate_Jrnl_Nrm,0) into vytd from debtor_month_control_totals where dRunMonth = vprevrunmonth and ifkPracticeInfoID = vpracid;
  
  set vmtd = ifnull(vmtd,0);
  set vmtclosed = ifnull(vmtclosed,0);
  set vytd = ifnull(vytd,0);
  
  set vopenbal = vytd  + vmtd;
  set vclosebal = vytd  + vmtclosed;
/*
  rest of the values for today
*/  

  select ipkDebtorTransActionType into vtranid from debtor_transAction_types where sTransactionTypeCode = 'feeadj';
  select ipkDebtorTransActionType into vsmallbalid from debtor_transAction_types where sTransactionTypeCode = 'smallwoff';
  
   select ifnull(sum(fAmount),0) into vfeestoday from debtor_transAction_types dt,debtor_dayend_totals de where de.ifkPracticeInfoID = vpracid  and de.dDate  = vday and de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType and sTransactionTypeCode in ('fee');
   select ifnull(sum(fAmount),0) into vjournalstoday from debtor_transAction_types dt,debtor_dayend_totals de where de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType and ((dt.bMoneyMovement = 0 and dt.sTransactionTypeCode not in ('fee','smallwoff','badwoff','handover','blacklst')) or (dt.bMoneyMovement = 1 and dt.sTransactionTypeCode not in ('receipt')))  and  ifkPracticeInfoID = vpracid and dDate = vday;   
   select ifnull(sum(fAmount),0) into vreceiptstoday from debtor_transAction_types dt,debtor_dayend_totals de where de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType and dt.bMoneyMovement = 1 and  ifkPracticeInfoID = vpracid and de.dDate = vday and dt.sTransactionTypeCode in ('receipt');   
   
   
   select ifnull(sum(fAmount),0) into vsmallbalancetoday from debtor_dayend_totals de where de.ifkPracticeInfoID = vpracid  and de.dDate  = vday and de.ifkDebtorTransActionType = vsmallbalid ;     
   
   
   select ifnull(sum(fAmount),0) into vbaddebttoday  from debtor_transAction_types dt,debtor_dayend_totals de where de.ifkDebtorTransActionType = dt.ipkDebtorTransActionType and dt.sTransactionTypeCode in ('badwoff','handover','blacklst') and  ifkPracticeInfoID = vpracid and dDate = vday;   
   
   select sum(fAmount + fVatAmount) into vwriteofftot from Debtor_WriteOff dw,accounts a ,sites s where dw.ifkAccountID = a.ipkAccountID and a.ifkSiteID  = s.ipkSiteID and s.ifkPracticeInfoID  = vpracid;
   
   select sum(fAmount) into vsuspensetot from debtor_suspense_account;
   
   select sum(fPaid)  into veraoutstandingtot  from debtor_vera_transActions where (bHandled = 0 or bHandled is null) ;
   
   set veraoutstandingtot = ifnull(veraoutstandingtot,0);
   set vsuspensetot = ifnull(vsuspensetot,0);
   set vbaddebttoday = ifnull(vbaddebttoday,0);
   set vsmallbalancetoday = ifnull(vsmallbalancetoday,0);
   set vreceiptstoday = ifnull(vreceiptstoday,0);
   set vjournalstoday = ifnull(vjournalstoday,0);
   set vfeestoday = ifnull(vfeestoday,0);
   set vwriteofftot = ifnull(vwriteofftot,0);
   
  
  select vopenbal,vclosebal,vfeestoday,vjournalstoday,vreceiptstoday,vsmallbalancetoday,vbaddebttoday,vwriteofftot,vsuspensetot,veraoutstandingtot,vpracid;
   
end$$

delimiter ;

