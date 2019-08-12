use `promed`;
drop procedure if exists `Debtor_ReportingDailyGraceList`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyGraceList`(in vday date,in vpracid bigint)
begin
  /*
    prints the daily hand over list , based on the day being used and those flagged to be on handoverlist
  */
  
  
declare vcurrweekday integer;
    declare vcurrmonthday integer;
    declare vcurrmonthdayback1 integer;
    declare vcurrmonthdayback2 integer;
    declare vprevmonth date;
    declare vprevlastday integer;
    declare vhomeid bigint;
    declare vpostalid bigint;
    

   set vcurrweekday = weekday(vday);
   
   set vcurrmonthday = dayofmonth(vday);
   set vcurrmonthdayback1 = vcurrmonthday - 1;
   set vcurrmonthdayback2 = vcurrmonthday - 2;
   
   if ((vcurrmonthdayback1 <= 0) or (vcurrmonthdayback2 <= 0)) then begin
       set vprevmonth = date_sub(vday, interval 1 month);
       set vprevlastday = dayofmonth(last_day(vprevmonth));
       if (vcurrmonthdayback1 <= 0) then begin
          set vcurrmonthdayback1 = vprevlastday - vcurrmonthdayback1;
       end; end if;
       if (vcurrmonthdayback2 <= 0) then begin
          set vcurrmonthdayback2 = vprevlastday - vcurrmonthdayback2;
       end; end if;
   end; end if;
   
   select ipkMemberAddressTypeID into vhomeid from member_address_type where sCode = 'h';
   select ipkMemberAddressTypeID into vpostalid from member_address_type where sCode = 'p';
   
   if ((vcurrweekday < 5) and (vcurrweekday > 0)) then begin
		select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,
         m.sWorktel,dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID,dg.iGraceDays,dg.sGraceDescription,
         mapa.sAddressLine1 as sposaladdress1,mapa.sAddressLine2 as sposaladdress2,mapa.sAddressLine3 as sposaladdress3,mapa.sAddressLine4 as sposaladdress4,mapa.sPostalCode as sposalCODE ,
         maha.sAddressLine1 as sHomeaddress1,maha.sAddressLine2 as sHomeaddress2,maha.sAddressLine3 as sHomeaddress3,maha.sAddressLine4 as sHomeaddress4,maha.sPostalCode as sHomeCODE 
		from debtor_graceperiod dg,accounts a, patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s,members m 
			left join member_addresses mapa on (mapa.ifkMemberAddressTypeID  = vpostalid and mapa.ifkMemberID = m.ipkMemberID)
            left join member_addresses maha on (maha.ifkMemberAddressTypeID  = vhomeid and maha.ifkMemberID = m.ipkMemberID)
		where a.ipkAccountID = da.ifkAccountID
		and a.ifkMemberID = m.ipkMemberID
		and a.ifkPatientID = p.ipkPatientID
		and m.ifkMedicalAidID = ma.ipkMedicalAidID
		and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
		and da.ifkAgeID = dag.ipkAgeID
		and da.bClosed = 0
		and s.ipkSiteID = a.ifkSiteID
        and s.ifkPracticeInfoID = vpracid
        and da.ifkDebtorGracePeriodID is not null
		and da.ifkDebtorGracePeriodID = dg.ipkDebtorGracePeriodID
		and dayofmonth(a.dExamDate) = vcurrmonthday 
		order by s.ifkPracticeInfoID,mat.sDescription,da.ifkAgeID,m.ssurname;
        
   end; else begin
      if (vcurrweekday = 0) then begin
			select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,m.sWorktel,
            dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID,dg.iGraceDays,dg.sGraceDescription,
         mapa.sAddressLine1 as sposaladdress1,mapa.sAddressLine2 as sposaladdress2,mapa.sAddressLine3 as sposaladdress3,mapa.sAddressLine4 as sposaladdress4,mapa.sPostalCode as sposalCODE ,
         maha.sAddressLine1 as sHomeaddress1,maha.sAddressLine2 as sHomeaddress2,maha.sAddressLine3 as sHomeaddress3,maha.sAddressLine4 as sHomeaddress4,maha.sPostalCode as sHomeCODE 
		from debtor_graceperiod dg,accounts a, patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s,members m 
			left join member_addresses mapa on (mapa.ifkMemberAddressTypeID  = vpostalid and mapa.ifkMemberID = m.ipkMemberID)
            left join member_addresses maha on (maha.ifkMemberAddressTypeID  = vhomeid and maha.ifkMemberID = m.ipkMemberID)
			where a.ipkAccountID = da.ifkAccountID
			and a.ifkMemberID = m.ipkMemberID
			and a.ifkPatientID = p.ipkPatientID
			and m.ifkMedicalAidID = ma.ipkMedicalAidID
			and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
			and da.ifkAgeID = dag.ipkAgeID
			and da.bClosed = 0
			and s.ipkSiteID = a.ifkSiteID
            and s.ifkPracticeInfoID = vpracid
            and da.ifkDebtorGracePeriodID is not null
			and da.ifkDebtorGracePeriodID = dg.ipkDebtorGracePeriodID
			and dayofmonth(a.dExamDate) in (vcurrmonthday,vcurrmonthdayback1,vcurrmonthdayback2) 
			order by s.ifkPracticeInfoID,mat.sDescription,da.ifkAgeID,m.ssurname;
     end; else begin
            /*make sure returns nothing*/
			select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,m.sWorktel,
            dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID,dg.iGraceDays,dg.sGraceDescription,
         mapa.sAddressLine1 as sposaladdress1,mapa.sAddressLine2 as sposaladdress2,mapa.sAddressLine3 as sposaladdress3,mapa.sAddressLine4 as sposaladdress4,mapa.sPostalCode as sposalCODE ,
         maha.sAddressLine1 as sHomeaddress1,maha.sAddressLine2 as sHomeaddress2,maha.sAddressLine3 as sHomeaddress3,maha.sAddressLine4 as sHomeaddress4,maha.sPostalCode as sHomeCODE 
		from debtor_graceperiod dg,accounts a, patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s,members m 
			left join member_addresses mapa on (mapa.ifkMemberAddressTypeID  = vpostalid and mapa.ifkMemberID = m.ipkMemberID)
            left join member_addresses maha on (maha.ifkMemberAddressTypeID  = vhomeid and maha.ifkMemberID = m.ipkMemberID)
			where a.ipkAccountID = da.ifkAccountID
			and a.ifkMemberID = m.ipkMemberID
			and a.ifkPatientID = p.ipkPatientID
			and m.ifkMedicalAidID = ma.ipkMedicalAidID
			and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
			and da.ifkAgeID = dag.ipkAgeID
			and da.bClosed = 999
			and s.ipkSiteID = a.ifkSiteID
            and da.ifkDebtorGracePeriodID is not null
			and da.ifkDebtorGracePeriodID = dg.ipkDebtorGracePeriodID
            and s.ifkPracticeInfoID = vpracid;
     end; end if;       
   
   end; end if;
  

end$$

delimiter ;

