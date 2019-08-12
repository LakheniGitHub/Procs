use `promed`;
drop procedure if exists `SearchQuote`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `SearchQuote`(in vsurname varchar(20),
												in vinitials varchar(5),
												in vfirstname varchar(15),
												in vidnumber varchar(13),
												in vdateofbirth date,
                                                in vcellphone varchar(15)) 
begin
	set @vquery = "select q.ipkQuoteID, q.dDateEntered, q.ifkTitleID, q.sFirstName, q.sInitials, q.sSurname, 
						q.sIDNumber, q.dDateOfBirth, q.sCell, q.sHome, q.sWork, q.sFax, q.ifkMedicalAidID, 
						q.ifkMedicalAidPlanID, q.sMemberNumber, q.ifkPrimaryDoctorID, q.ifkaccountID, q.bLinked, q.ifkBookingID, 
						q.fQuoteTotal, q.fFeeFactor, q.fFeeSpecialAmount, q.ifkFeeingTypeID,ma.sCode as medicalaidcode,ma.sName as medicalaidname,
						map.sGlobalMedicalAidCode as globalmedicalaidcode,b.sBookingCode,a.sAccountCode,
					    map.sOptionName as medicalaidplanname,concat('q',q.ipkQuoteID) as squotenumber
						from quote q	left join medical_aid ma on ma.ipkMedicalAidID = q.ifkMedicalAidID
					left join medical_aid_plan map on map.ipkMedicalAidPlanID = q.ifkMedicalAidPlanID 
					left join bookings b on b.ipkBookingID = q.ifkBookingID 
					left join accounts a on a.ipkAccountID = q.ifkaccountID
					where q.ipkQuoteID > 0 ";
    
    if (vsurname is not null) or (vsurname <> '') then
		begin
			
            set @vquery = concat(@vquery, " and q.sSurname like '", vsurname, "%'");
        end;
	end if;
	
    if (vinitials is not null) or (vinitials <> '') then
		begin
			
            set @vquery = concat(@vquery, " and q.sInitials like '", vinitials, "%'");
        end;
	end if;
    
    if (vfirstname is not null) or (vfirstname <> '') then
		begin
			
            set @vquery = concat(@vquery, " and q.sFirstName like '", vfirstname, "%'");
        end;
	end if;
	
    if (vidnumber is not null) or (vidnumber <> '') then
		begin
			
            set @vquery = concat(@vquery, " and q.sIDNumber like '", vidnumber, "%'");
        end;
	end if;
	
    if ((vdateofbirth is not null) and (vdateofbirth <> '1899/12/30')) then
		begin
			
            set @vquery = concat(@vquery, " and q.dDateOfBirth = '", vdateofbirth, "'");
        end;
	end if;
    
    if (vcellphone is not null) or (vcellphone <> '') then
		begin
			
            set @vquery = concat(@vquery, " and q.sCell like '", vcellphone, "%'");
        end;
	end if;
    

    prepare stmtsearchquote from @vquery;
	execute stmtsearchquote; 
    deallocate prepare stmtsearchquote;
end$$

delimiter ;

