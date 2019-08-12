use `promed`;
drop procedure if exists `Debtor_ReportingAgeAnalysis`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingAgeAnalysis`(in vpracid bigint) /*in vdate date,*/
begin

/*  declare vstartdate timestamp;
  declare vendDate timestamp;
  declare iyear integer;
  declare imonth integer;
  declare v_feetransTypeid bigint;
  declare  vyear integer;
  declare  vmonth integer;
  declare   vquarter integer;
  
  call DebtorPracticeFiscalInfoForDate(vpracid,vdate,vyear,vquarter,vmonth);
  */
  
	select s.ifkPracticeInfoID,s.sSiteName, b.sBranchCode,b.sDescription as sbrancNAME, a.sAccountCode,a.dExamDate,m.sInitials,m.ssurname,ma.sCode as sMedAidCode,a.fBalance,dag.sAgeName, case 
	when  dag.sAgeCode = '0' then 'current' else dag.sAgeCode end as sAgeCode,
	debtor_last_receipt_amount(ifkAccountID) as flastrceiptamount,debtor_last_receipt_date(ifkAccountID) as dLastReceiptDate
	from accounts a, debtor_additional da,members m,sites s,medical_aid ma,debtor_age_groups dag,Branches b
	where a.ipkAccountID = da.ifkAccountID
	and a.ifkSiteID = s.ipkSiteID
	and m.ifkMedicalAidID = ma.ipkMedicalAidID
	and a.ifkMemberID  = m.ipkMemberID
	and da.ifkAgeID = dag.ipkAgeID
	and a.ifkBranchID = b.ipkBranchID
	and s.ifkPracticeInfoID = vpracid
	and da.bClosed = 0;
  
  
end$$

delimiter ;

