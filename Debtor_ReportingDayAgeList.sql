use `promed`;
drop procedure if exists `Debtor_ReportingDayAgeList`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDayAgeList`(in vday date, in vpracid bigint)
begin
    declare vcurrweekday integer;
    declare vcurrmonthday integer;
    declare vcurrmonthdayback1 integer;
    declare vcurrmonthdayback2 integer;
    declare vprevmonth date;
    declare vprevlastday integer;
    

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
   
   if ((vcurrweekday < 5) and (vcurrweekday > 0)) then begin
		select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,m.sWorktel,dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID
		from accounts a, members m,patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s
		where a.ipkAccountID = da.ifkAccountID
		and a.ifkMemberID = m.ipkMemberID
		and a.ifkPatientID = p.ipkPatientID
		and m.ifkMedicalAidID = ma.ipkMedicalAidID
		and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
		and da.ifkAgeID = dag.ipkAgeID
		and da.bClosed = 0
		and s.ipkSiteID = a.ifkSiteID
        and s.ifkPracticeInfoID = vpracid
		and dayofmonth(a.dExamDate) = vcurrmonthday 
		order by s.ifkPracticeInfoID,mat.sDescription,da.ifkAgeID,m.ssurname;
        
   end; else begin
      if (vcurrweekday = 0) then begin
			select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,m.sWorktel,dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID
			from accounts a, members m,patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s
			where a.ipkAccountID = da.ifkAccountID
			and a.ifkMemberID = m.ipkMemberID
			and a.ifkPatientID = p.ipkPatientID
			and m.ifkMedicalAidID = ma.ipkMedicalAidID
			and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
			and da.ifkAgeID = dag.ipkAgeID
			and da.bClosed = 0
			and s.ipkSiteID = a.ifkSiteID
            and s.ifkPracticeInfoID = vpracid
			and dayofmonth(a.dExamDate) in (vcurrmonthday,vcurrmonthdayback1,vcurrmonthdayback2) 
			order by s.ifkPracticeInfoID,mat.sDescription,da.ifkAgeID,m.ssurname;
     end; else begin
            /*make sure returns nothing*/
			select a.sAccountCode,m.sInitials,m.ssurname,p.sName,ma.sCode,m.sMedicalAidReference,a.dExamDate,ifnull(a.fBalance,0) as vbalance,m.sCellphone,m.sHometel,m.sWorktel,dag.sAgeName,mat.sDescription,s.ifkPracticeInfoID
			from accounts a, members m,patients p,medical_aid ma, medical_aid_type mat,debtor_additional da,debtor_age_groups dag,sites s
			where a.ipkAccountID = da.ifkAccountID
			and a.ifkMemberID = m.ipkMemberID
			and a.ifkPatientID = p.ipkPatientID
			and m.ifkMedicalAidID = ma.ipkMedicalAidID
			and ma.ifkMedicalAidTypeID = mat.ipkMedicalAidTypeID
			and da.ifkAgeID = dag.ipkAgeID
			and da.bClosed = 999
			and s.ipkSiteID = a.ifkSiteID
            and s.ifkPracticeInfoID = vpracid;
     end; end if;       
   
   end; end if;

end$$

delimiter ;

