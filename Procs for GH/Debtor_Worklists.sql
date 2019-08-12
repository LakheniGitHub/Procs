use `promed`;
drop procedure if exists `Debtor_Worklists`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_Worklists`(in vworklisttype varchar(20),
														in voperatorid bigint, 
                                                        in vdatestart date, 
                                                        in vdateend date)
begin
   /*
     8 oct 2018
     johannes
     
     purpose is to have a central point to call worklsits used in prism worklist screen for debtors only.
     the worklist type will deterMINe what query is used and returened
     
     vworklisttype
     =============
     general
     reMINder
     30day
     errorlist
     
   */
   
   /* 
   
   05 april 2019
   devon
   
   changed procedure to only use one query that returns more of the same data as patient waiting and then using inputs to change where clause 
   
   */
   
   declare vageid integer;
   declare verrorlist varchar(80);
   declare vnonclosedonly integer;
   declare vhandled integer;
   declare vLINEcount integer;
   
   set vageid = null;
   set verrorlist = null;
   set vnonclosedonly = null;
   set vhandled = null;
   set vLINEcount = null;
   
   
   if ((vworklisttype = '') or (vworklisttype is null)) then begin
      set vworklisttype = 'general';
   end; end if;
   
   /* global query can be overwritten ** */
     set @vquery = concat("select distinct 
							a.ipkAccountID as accountid,
                            a.sAccountCode as account, 
                            a.dDateEntered as dateentered,
                            a.fBalance as originalbalance,
                            a.ifkFeeMedicalAidID as medicalaidid,
                            a.iLINECount,
                            
                            dag.sAgeName as debtorage,
                            dgp.sGraceDescription as debtorgrace,
							da.bClosed as closed,
                            da.bHandOver as handover,
                            da.bBadDebt as baddebt,
                            da.bBlackListed as blacklisted,
                            da.bPaymentAgreement as paymentagreement,
                            da.sEligStatusMessage,
                            da.iEligStatusNumber,
                            da.sEligStatus,
                            
                            a.ifkMemberID as memberid,
							m.sTITLE as memberTITLE, 
							m.ssurname as membersurname, 
							m.sName as memberfirstNAME, 
                            m.sInitials as memberinitials,
							concat(m.ssurname, ', ', m.sName, ', ', m.sTITLE) as memberfullNAME,
                            m.sIDNumber as memberidNUMBER,
							m.ifkMedicalAidID,
                            m.ifkMedicalAidPlanID,
                            m.sMedicalAidReference as medicalaidREFERENCE,
                            
							p.ipkPatientID as patientid,
							p.sTITLE as patientTITLE, 
							p.ssurname as patientsurname, 
							p.sName as patientfirstNAME, 
                            p.sInitials as patientinitials,
							concat(p.ssurname, ', ', p.sName, ', ', p.sTITLE) as patientfullNAME,
                            p.sIDNumber as patientidNUMBER,        
                            
							case p.dDateOfBirth 
								when '0000-00-00' then '1899-12-30'
								else p.dDateOfBirth
							end as patientdateofbirth,                              
                            
							truncate(datediff(current_timestamp, p.dDateOfBirth) /365, 0) as patientage, 
                            p.sUID as patientuid,   
							
							s.sSiteName as siteNAME, 
							s.sSiteFolder,
                            
							b.sBranchCode as BranchCODE, 
                            b.sDescription as BranchNAME,							
                            
							w.sCode as WARDCODE,
                            w.sDescription as WARDNAME,
                            
							ma.sCode as medicalaidCODE, 
                            ma.sName as medicalaidNAME,
                            
                            map.sMedicalAidOption as medicalaidoption,
                            
							concat(prd.ssurname, ' ', prd.sInitials, ' ', prd.sTITLE) as primaryrefdocNAME,
							prd.stel as primaryrefdoctel,
							concat(srd.ssurname, ' ', srd.sInitials, ' ', srd.sTITLE) as secondaryrefdocNAME,
							srd.stel as secondaryrefdoctel,
                            
                            opl.ipkOperatorID as lockedbyid,
                            concat(opl.sFirstNames, ' ', opl.sLastName) as lockedbyfullNAME,
                            
                            dr.sReminderMessage as reMINdermessage, 
                            dr.bHandled as reMINderhandled, 
                            dr.dReMINderDate as reMINderdate, 
                            
                            opr.ipkOperatorID as reMINderbyid,
                            concat(opr.sFirstNames, ' ', opr.sLastName) as reMINderbyfullNAME,
                            
                            et.dPatientValidationDate as edidate,
											
							case map.sPV when 'n' then '' else PVets.sStatusName end as spatientvalidation,
							case map.sPC when 'n' then '' else case ifnull(PCets.ipkEligTransActionStatusID,9999) when 11 then '' when 15 then '' else PCets.sStatusName end end as spracticeclaim,
							case map.sPCR when 'n' then '' else case ifnull(PCets.ipkEligTransActionStatusID,9999) when 11 then 'reversal success' when 15 then 'reversal submitted' else '' end end as spracticeclaimrefersal,
							case map.sBC when 'n' then '' else BFCets.sStatusName end as sbenefitcheck,
							case map.sFC when 'n' then '' else FCets.sStatusName end as sfundcheck
            
			from accounts a 
				
			inner join debtor_additional da on da.ifkAccountID = a.ipkAccountID  
			inner join debtor_age_groups dag on dag.ipkAgeID = da.ifkAgeID  
            left join debtor_reMINders dr on dr.ifkAccountID = a.ipkAccountID 
            left join debtor_graceperiod dgp on dgp.ipkDebtorGracePeriodID = da.ifkDebtorGracePeriodID
            
            inner join Branches b on b.ipkBranchID = a.ifkBranchID
            inner join WARDs w on w.ipkWARDID = a.ifkWARDID
            inner join sites s on s.ipkSiteID = a.ifkSiteID
            inner join patients p on p.ipkPatientID = a.ifkPatientID
            inner join members m on m.ipkMemberID = a.ifkMemberID
            
            left join medical_aid ma on ma.ipkMedicalAidID = m.ifkMedicalAidID
            left join medical_aid_plan map on map.ipkMedicalAidPlanID = m.ifkMedicalAidPlanID
            left join referring_doctors prd on prd.ipkReferringDoctorID = a.ifkPrimaryReferringDoctorID
            left join referring_doctors srd on srd.ipkReferringDoctorID = a.ifkSecondaryReferringDoctorID
            left join operators opl on opl.ipkOperatorID = a.ifkLockedByOperatorsID
            left join operators opr on opr.ipkOperatorID = dr.ifkOperatorID
            
			left join ELIG_transActions et on et.ifkAccountID = a.ipkAccountID 
			left join ELIG_transAction_statuses FCets on et.iFundCheckStatus = FCets.iStatusNumber  
			left join ELIG_transAction_statuses BFCets on et.iBenefitCheckStatus = BFCets.iStatusNumber  
			left join ELIG_transAction_statuses PCets on et.iPracticeClaimStatus = PCets.iStatusNumber  
			left join ELIG_transAction_statuses PVets on et.iPatientValidationStatus = PVets.iStatusNumber  
            
			where a.bActive = 1 
				and a.bDeleted = 0");	

						
   /* ********************* general *****************************/
   if (vworklisttype = 'general') then begin
     set vnonclosedonly = 1;           
   end; end if;

   /* ********************* reMINder *****************************/
   if (vworklisttype = 'reMINder') then begin
	 set vhandled = 0;
   end; end if;

   /* ********************* 30day *****************************/
   if (vworklisttype = '30day') then begin
       set vageid = 30; /*use 30day+*/
	   set vnonclosedonly = 1;           
   end; end if;

   /* ********************* errorlist *****************************/
   if (vworklisttype = 'errorlist') then begin
	/*
    -100 : no sys message
    -1 : error 
    0 : submitted
    1 : partial success 
    2 : success
    3 : success+
    6 : waiting
    7 : delayed
    9 : rejected
    11 : reversal success
    15 : reversal submitted
	*/   
      set verrorlist = '-100,-1,9';
   end; end if;
   
   /* ********************* unFEED *****************************/
   if (vworklisttype = 'unFEED') then begin
	   set vLINEcount = 0;         
   end; end if;
   
   if (voperatorid > 0) then begin
     set @vquery = concat(@vquery, " and da.ifkAssignedID = ", voperatorid);
   end; end if;
   
    if (vdatestart is not null) then begin
		set @vquery = concat(@vquery, " and a.dDateEntered >= '", vdatestart, "'");
	end ; end if;
    
    if (vdateend is not null) then begin
		set @vquery = concat(@vquery, " and a.dDateEntered <= '", vdateend, "'");
	end; end if;
	
	if (vageid is not null) then begin
	  set @vquery = concat(@vquery, " and dag.iAgeDaysEnd >= ", vageid);
	end; end if;
	
	if (verrorlist is not null) then begin
	   set @vquery = concat(@vquery, " and iEligProcessed = 0  and da.iEligStatusNumber in (", verrorlist,')');
	end; end if;
	
	if (vnonclosedonly is not null) then begin
	  set @vquery = concat(@vquery, " and da.bClosed = 0");
	end; end if;
    
	if (vhandled is not null) then begin
	  set @vquery = concat(@vquery, " and dr.bHandled = 0");
	end; end if;
    
	if (vLINEcount is not null) then begin
	  set @vquery = concat(@vquery, " and a.iLINECount = 0");
	end; end if;
   
    prepare stmtdebtorworklistsqry from @vquery;
	execute stmtdebtorworklistsqry;
    deallocate prepare stmtdebtorworklistsqry;
   
end$$

delimiter ;

