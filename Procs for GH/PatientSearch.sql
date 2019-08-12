use `promed`;
drop procedure if exists `PatientSearch`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `PatientSearch`(in vsurname varchar(80),
								in vinitials varchar(10),
                                in vidnumber varchar(20),
                                in vcellphone varchar(15),
                                in vdateofbirth date,
                                in vuid varchar(64))
begin
	set @vquery = "select distinct 	p.ipkPatientID as patientcode,
							p.ifkOriginalPatientID as originalpatientcode,
							p.sTitle as patienttitle,
							p.sInitials as patientinitials,
							p.sName as patientname,
							p.sSurname as patientsurname,
							p.sIDNumber as patientidnumber,
							p.dDateOfBirth as patientdateofbirth,
                            year(current_timestamp) - year(p.dDateOfBirth) - (date_format(current_timestamp, '%m%d') < date_format(p.dDateOfBirth, '%m%d')) as patientage,
							p.dDateEntered as patientdateentered,
							p.iPDependantNo as patientpdependantno,
							p.bAppointment as patientappointment,
							p.sUID as patientuid,
							p.bActive as patientactive,
							p.bNonSAID as patientnonsaid,
							p.bSmoking as patientsmoking,
							p.bVIP as patientvip,
							p.bConsent as patientconsent,
							p.bParentConsent as patientparentconsent,
							p.sAllergies as patientallergies,
							p.sOccupation as patientoccupation,
							p.blPatientInfo as patientinfo,
							p.sCompanyName as patientcompanyname,
							p.iWeight as patientweight,
							p.bValves as patientvalves,
							p.bAsthma as patientasthma,
							p.bPregnant as patientpregnant,
							p.bPacemaker as patientpacemaker,
							p.bMetalInHead as patientmetalinhead,
							p.bClips as patientclips,
							p.sCellphone as patientcellphone,
							p.sSex as patientsex,
							p.sLanguage as patientlanguage,
							p.sEmail as patientemail,
							p.sEmployeeNumber as patientemployeenumber,
							p.sFax as patientfax,
							p.sComsPreference as patientcomspreference,
                            p.sHomeTel as patienthometel,
                            p.sWorkTel as patientworktel,
                            m.ipkMemberID as membercode,
							m.dDateEntered as memberdateentered,
							m.dMemberDateOfBirth as memberdateofbirth,
							m.sMedicalAidClaim as membermedicalaidclaim,
							m.iDependants as memberdependants,
							m.sVatNo as membervatno,
							m.sTitle as membertitle,
							m.sInitials as memberinitials,
							m.sName as membername,
							m.sNextOfKinName as membernextofkinname,
							m.sNextOfKinRelation as membernextofkinrelation,
							m.bNonSAID as membernonsaid,
							m.bConsent as memberconsent,
							m.sMedicalAidReference as membermedicalaidref,
							m.sIDNumber as memberidnumber,
							m.sCellphone as membercellphone,
							m.sNextOfKinTel as membernextofkintel,
							m.sEmployer as memberemployer,
							m.sOccupation as memberoccupation,
							m.sWorkDepartment as memberworkdepartment,
							m.sFax as memberfax,
							m.sEmail as memberemail,
							m.sEmployeeNumber as memberemployeenumber,
							m.sCompanyNumber as membercompanynumber,
							m.sRelation as memberrelation,
							m.sSurname as membersurname,
                            m.sHomeTel as memberhometel,
                            m.sWorkTel as memberworktel,
                            r.sDescription as relation,
                            r.sCode as relationcode,
                            ma.sCode as medicalaidcode,
                            ma.sName as medicalaidname,
                            map.sGlobalMedicalAidCode as globalmedicalaidcode,
                            map.sOptionName as medicalaidplanname,
                            mahom.sAddressLine1 as homeaddressline1,
                            mahom.sAddressLine2 as homeaddressline2,
                            mahom.sAddressLine3 as homeaddressline3,
                            mahom.sAddressLine4 as homeaddressline4,
                            mahom.sPostalCode as homepostalcode,
							marel.sAddressLine1 as relativeaddressline1,
                            marel.sAddressLine2 as relativeaddressline2,
                            marel.sAddressLine3 as relativeaddressline3,
                            marel.sAddressLine4 as relativeaddressline4,
                            marel.sPostalCode as relativepostalcode,
							mapos.sAddressLine1 as postaladdressline1,
                            mapos.sAddressLine2 as postaladdressline2,
                            mapos.sAddressLine3 as postaladdressline3,
                            mapos.sAddressLine4 as postaladdressline4,
                            mapos.sPostalCode as postalcode,
							mawor.sAddressLine1 as workaddressline1,
                            mawor.sAddressLine2 as workaddressline2,
                            mawor.sAddressLine3 as workaddressline3,
                            mawor.sAddressLine4 as workaddressline4,
                            mawor.sPostalCode as workpostalcode,
                            m.ifkMedicalAidID
					from patients p
                    left join accounts a
						on a.ifkPatientID = p.ipkPatientID
					left join members m
						on a.ifkMemberID = m.ipkMemberID
					left join member_address_groups mahom
						on mahom.ifkMemberID = m.ipkMemberID and mahom.sCode = 'H'
					left join member_address_groups marel
						on marel.ifkMemberID = m.ipkMemberID and marel.sCode = 'R'
					left join member_address_groups mapos
						on mapos.ifkMemberID = m.ipkMemberID and mapos.sCode = 'P'
					left join member_address_groups mawor
						on mawor.ifkMemberID = m.ipkMemberID and mawor.sCode = 'E'
					left join relations r
						on r.ipkRelationID = p.ifkRelationID
					left join medical_aid ma
						on ma.ipkMedicalAidID = m.ifkMedicalAidID
					left join medical_aid_plan map
						on map.ipkMedicalAidPlanID = m.ifkMedicalAidPlanID
					where p.bActive = 1 ";
	
    if (vsurname is not null) and (vsurname <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sSurname like '", vsurname, "%'");
        end;
	end if;
	
    if (vinitials is not null) and (vinitials <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sInitials like '", vinitials, "%'");
        end;
	end if;
	
    if (vidnumber is not null) and (vidnumber <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sIDNumber like '", vidnumber, "%'");
        end;
	end if;
	
    if (vcellphone is not null) and (vcellphone <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sCellphone like '", vcellphone, "%'");
        end;
	end if;
	
    if /*(vdateofbirth is not null) or */(vdateofbirth <> '1899/12/30') then
		begin
			
            set @vquery = concat(@vquery, " and p.dDateOfBirth = '", vdateofbirth, "'");
        end;
	end if;
    
    if (vuid is not null) and (vuid <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sUID like '", vuid, "%'");
        end;
	end if; 

    prepare stmtpatientsearch from @vquery;
	execute stmtpatientsearch;
    deallocate prepare stmtpatientsearch;
end$$

delimiter ;

