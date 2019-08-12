delimiter $$
create definer=`root`@`localhost` procedure `CreatePatientMinimum`(in vsurname varchar(20),
										in vNAME varchar(20),
										in vinitials varchar(5),
										in vTITLE varchar(5),
										in vdateofbirth timestamp,
										in vidNUMBER varchar(15),
										in vmedicalaidCODE varchar(6),
										in vmedicalaidNUMBER varchar(25),
										in vmedicalaidplan varchar(10),
										out vpatientCODE integer)
begin

	declare vmemberid integer;

    insert into members (ifkMedicalAidID, sMedicalAidReference, ifkMedicalAidPlanID)
    values ((select ipkMedicalAidID from medical_aid ma where ma.sCode = vmedicalaidCODE), vmedicalaidNUMBER, (select map.ipkMedicalAidPlanID from medical_aid_plan map where map.sOptionName = vmedicalaidplan));

	set vmemberid = (select @@identity);

    insert into memberaddress (ifkMemberID, smemberaddressTypeid)
    values (vmemberid, 'h');
    insert into memberaddress (ifkMemberID, smemberaddressTypeid)
    values (vmemberid, 'p');
    insert into memberaddress (ifkMemberID, smemberaddressTypeid)
    values (vmemberid, 'e');
    insert into memberaddress (ifkMemberID, smemberaddressTypeid)
    values (vmemberid, 'r');

    insert into patients (ssurname, sName, sInitials, sTITLE, dDateOfBirth, sIDNumber, ifkMemberID)
    values (vsurname, vNAME, vinitials, vTITLE, vdateofbirth, vidNUMBER, vmemberid);

    set vpatientCODE = (select @@identity);
end$$
delimiter ;
