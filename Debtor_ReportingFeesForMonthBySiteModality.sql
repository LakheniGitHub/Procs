use `promed`;
drop procedure if exists `Debtor_ReportingFeesForMonthBySiteModality`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingFeesForMonthBySiteModality`(in vdate date,in vpracid bigint) /* in vyear integer, in vmonth integer*/
begin

  declare vstartdate timestamp;
  declare vendDate timestamp;
  declare iyear integer;
  declare imonth integer;
  declare v_feetransTypeid bigint;
  
  /*set iyear  = year(vdate);
  set imonth = month(vdate);
  set vstartdate = concat(iyear,'-',imonth,'-01');
  
  set vendDate = last_day(vdate);
  set vendDate = timestampadd(hour,23,vendDate);
  set vendDate = timestampadd(MINute,59,vendDate);
  set vendDate = timestampadd(second,59,vendDate);
  */
  declare  vyear integer;
  declare  vmonth integer;
  declare   vquarter integer;
  
  call DebtorPracticeFiscalInfoForDate(vpracid,vdate,vyear,vquarter,vmonth);
  
    select ipkDebtorTransActionType into v_feetransTypeid from debtor_transAction_types where sTransactionTypeCode = 'feeadj';
	
	drop temporary table if exists tmPCharges; 
  create temporary table if not exists tmPCharges engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,s.sSiteName,da.ifkModalityID,
											case when da.ifkModalityID is null then 'unal' else m.sModalityCode end as sModalityCode,
											case when da.ifkModalityID is null then 'unallocated items' else m.sDescription end as sDescription,
											count(distinct(a.ipkAccountID)) as iaccountcount,count(dsa.ipkStatementAuditID) as iLINEitems,
											sum(dsa.fTransActionAmount) as ftransActiontotal,sum(dsa.fVatAmount) as fVatAmounttotal,000000000000000000.00 as fexamtot,000000000000000000.00 as fmaterialstotal,
												000000000000000000.00 as FContrastotals,000000000000000000.00 as fafterhourstotal,000000000000000000.00 as funallocatedtotal,vyear,vmonth
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	/*and (dsa.sTarrifCode is not null and dsa.sTarrifCode <> '')*/
	group by  s.ifkPracticeInfoID,s.ipkSiteID,s.sSiteName,da.ifkModalityID,m.sModalityCode, m.sDescription);
	
	drop temporary table if exists tmpmaterial; 
  create temporary table if not exists tmpmaterial engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID,sum(dsa.fTransActionAmount) as fAmounttotal
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	and dsa.sTarrifCode = '00090'
	group by  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID);
	
	drop temporary table if exists tmPContras; 
  create temporary table if not exists tmPContras engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID,sum(dsa.fTransActionAmount) as fAmounttotal
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	and dsa.sTarrifCode in ( '00190', '00290', '00390', '00490', '00590', '00990', '00991')
	group by  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID);	
	
	drop temporary table if exists tmpafterhours; 
  create temporary table if not exists tmpafterhours engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID,sum(dsa.fTransActionAmount) as fAmounttotal
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	and dsa.sTarrifCode = '01020'
	group by  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID);
	
	drop temporary table if exists tmpunknown; 
  create temporary table if not exists tmpunknown engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID,sum(dsa.fTransActionAmount) as fAmounttotal
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	and (dsa.sTarrifCode is null or dsa.sTarrifCode = '')
	group by  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID);	
	
drop temporary table if exists tmpexam; 
  create temporary table if not exists tmpexam engine=memory  as  (
		select  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID,sum(dsa.fTransActionAmount) as fAmounttotal
	from debtor_statement_audit dsa,accounts a,sites s,debtor_additional da left join modalities m on da.ifkModalityID = m.ipkModalityID
	where /*dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate*/
	dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth =vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	and dsa.ifkDebtorTransActionType = v_feetransTypeid
    and da.ifkAccountID = a.ipkAccountID
	and (dsa.sTarrifCode is not null and dsa.sTarrifCode <> '')
	and dsa.sTarrifCode not in ( '00190', '00290', '00390', '00490', '00590', '00990', '00991','00090','01020')
	group by  s.ifkPracticeInfoID,s.ipkSiteID,da.ifkModalityID);	
	

   	update tmPCharges tc, tmpunknown tmp 
	   set tc.funallocatedtotal = tmp.fAmounttotal
	   where tc.ifkPracticeInfoID = tmp.ifkPracticeInfoID
	   and tc.ipkSiteID = tmp.ipkSiteID
	   and tc.ifkModalityID = tmp.ifkModalityID;
	   
   	update tmPCharges tc, tmpafterhours tmp 
	   set tc.fafterhourstotal = tmp.fAmounttotal
	   where tc.ifkPracticeInfoID = tmp.ifkPracticeInfoID
	   and tc.ipkSiteID = tmp.ipkSiteID
	   and tc.ifkModalityID = tmp.ifkModalityID;	

	 update tmPCharges tc, tmPContras tmp 
	   set tc.FContrastotals = tmp.fAmounttotal
	   where tc.ifkPracticeInfoID = tmp.ifkPracticeInfoID
	   and tc.ipkSiteID = tmp.ipkSiteID
	   and tc.ifkModalityID = tmp.ifkModalityID;

	 update tmPCharges tc, tmpmaterial tmp 
	   set tc.fmaterialstotal = tmp.fAmounttotal
	   where tc.ifkPracticeInfoID = tmp.ifkPracticeInfoID
	   and tc.ipkSiteID = tmp.ipkSiteID
	   and tc.ifkModalityID = tmp.ifkModalityID;
	   
	 update tmPCharges tc, tmpexam tmp 
	   set tc.fexamtot = tmp.fAmounttotal
	   where tc.ifkPracticeInfoID = tmp.ifkPracticeInfoID
	   and tc.ipkSiteID = tmp.ipkSiteID
	   and tc.ifkModalityID = tmp.ifkModalityID;
	   
	   
	select * from tmPCharges;
end$$

delimiter ;

