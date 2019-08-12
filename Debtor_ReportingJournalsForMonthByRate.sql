use `promed`;
drop procedure if exists `Debtor_ReportingJournalsForMonthByRate`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingJournalsForMonthByRate`(in vdate date ,in vpracid bigint)
begin

  declare vstartdate timestamp;
  declare vendDate timestamp;
/*  declare iyear integer;
  declare imonth integer;*/
  declare vyear integer;
  declare vmonth integer;
  declare   vquarter integer;
     call DebtorPracticeFiscalInfoForDate(vpracid,vdate,vyear,vquarter,vmonth);
  
  /*set iyear  = year(vdate);
  set imonth = month(vdate);
  set vstartdate = concat(iyear,'-',imonth,'-01');
  
  set vendDate = last_day(vdate);
  set vendDate = timestampadd(hour,23,vendDate);
  set vendDate = timestampadd(MINute,59,vendDate);
  set vendDate = timestampadd(second,59,vendDate);
  */
  
	select  vyear,vmonth,s.ifkPracticeInfoID, m.iRateCode,count(dsa.ifkAccountID) as iaccountcount,sum(dsa.fTransActionAmount) as ftransActiontotal
	from debtor_statement_audit dsa,medical_aid m,accounts a,sites s
	where m.ipkMedicalAidID = dsa.ifkFeeMedicalAidID
	/*and dsa.dDateEntered >= vstartdate
	and dsa.dDateEntered <= vendDate
	*/
	and dsa.iRunFiscalYear = vyear
	and dsa.iRunFiscalMonth = vmonth
    and a.ipkAccountID = dsa.ifkAccountID
    and a.ifkSiteID = s.ipkSiteID
	and s.ifkPracticeInfoID = vpracid
	group by  vyear,vmonth,s.ifkPracticeInfoID,m.iRateCode;
  
  
end$$

delimiter ;

