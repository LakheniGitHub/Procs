use `promed`;
drop procedure if exists `LookupPatient`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `LookupPatient`(in vsurname varchar(80),
								in vinitials varchar(5),
								in vfirstname varchar(80),
                                in vidnumber varchar(20),
                                in vcellphone varchar(20),
                                in vdateofbirth date,
                                in vuid varchar(64)) 
begin
	set @vquery = "select distinct  p.ipkPatientID as patientcode,
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
									r.sDescription as relation,
									r.sCode as relationcode
					from patients p
                    left join accounts a on a.ifkPatientID = p.ipkPatientID
					left join relations r on r.ipkRelationID = p.ifkRelationID
					where p.bActive = 1";
	
    if (vsurname is not null) or (vsurname <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sSurname like '", vsurname, "%'");
        end;
	end if;
	
    if (vinitials is not null) or (vinitials <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sInitials like '", vinitials, "%'");
        end;
	end if;
    
    if (vfirstname is not null) or (vfirstname <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sName like '", vfirstname, "%'");
        end;
	end if;
	
    if (vidnumber is not null) or (vidnumber <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sIDNumber like '", vidnumber, "%'");
        end;
	end if;
	
    if (vcellphone is not null) or (vcellphone <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sCellphone like '", vcellphone, "%'");
        end;
	end if;
	
    if ((vdateofbirth is not null) and (vdateofbirth <> '1899/12/30')) then
		begin
			
            set @vquery = concat(@vquery, " and p.dDateOfBirth = '", vdateofbirth, "'");
        end;
	end if;
    
    if (vuid is not null) or (vuid <> '') then
		begin
			
            set @vquery = concat(@vquery, " and p.sUID like '", vuid, "%'");
        end;
	end if; 

    prepare stmtlookuppatient from @vquery;
	execute stmtlookuppatient;
    deallocate prepare stmtlookuppatient;
end$$

delimiter ;

