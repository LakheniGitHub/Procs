use `promed`;
drop procedure if exists `PatientCapture`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `PatientCapture`(in vmemberid integer, -- 1
								in vpatientid integer, -- 2
                                in vaccountcode varchar(8), -- 3
                                in vmedicalaidcode varchar(10), -- 4
                                in vmedicalaidplancode varchar(10), -- 5
                                in vmemberdateofbirth date, -- 6
								in vvatno varchar(20), -- 7 
								in vmembertitle varchar(10), -- 8
								in vmemberinitials varchar(10), -- 9
								in vmemberfirstname varchar(50), -- 10
                                in vmembersurname varchar(20), -- 11
								in vmembernonsaid tinyint, -- 12
								in vpatientconsent tinyint, -- 13
								in vmedicalaidreference varchar(20), -- 14
								in vmemberidnumber varchar(20), -- 15
								in vmembercellphone varchar(20), -- 16
								in vnextofkintel varchar(20), -- 17
								in vmemberfax varchar(20), -- 18
								in vmemberemail varchar(50), -- 19
                                in vmemberpostaladdress1 varchar(255), -- 20
                                in vmemberpostaladdress2 varchar(255), -- 21
                                in vmemberpostaladdress3 varchar(255), -- 22
                                in vmemberpostaladdress4 varchar(255), -- 23
                                in vmemberpostaladdresscode varchar(255), -- 24
                                in vmemberhomeaddress1 varchar(255), -- 25
                                in vmemberhomeaddress2 varchar(255), -- 26
                                in vmemberhomeaddress3 varchar(255), -- 27
                                in vmemberhomeaddress4 varchar(255), -- 28
                                in vmemberhomeaddresscode varchar(255), -- 29
                                in vmembernextofkinaddress1 varchar(255), -- 30
                                in vmembernextofkinaddress2 varchar(255), -- 31
                                in vmembernextofkinaddress3 varchar(255), -- 32
                                in vmembernextofkinaddress4 varchar(255), -- 33
                                in vmembernextofkinaddresscode varchar(255), -- 34
                                in vmemberworktel varchar(20), -- 35
                                in vmemberhometel varchar(20), -- 36
                                in vpatienttitle varchar(10), -- 37
                                in vpatientsurname varchar(50), -- 38
								in vpatientsex varchar(1), -- 39
                                in vpatientfirstname varchar(50), -- 40
                                in vpatientinitials varchar(5), -- 41
                                in vpatientdateofbirth date, -- 42
                                in vpatientidnumber varchar(20), -- 43
                                in vpatientnonsaid tinyint, -- 44
                                in vpatientrelationtomember varchar(50), -- 45
                                in vpatientdependantno integer, -- 46
                                in vpatientoccupation varchar(50), -- 47
                                in vpatientasthma tinyint, -- 48
                                in vpatientallergies varchar(50), -- 49
                                in vpatientemail varchar(100), -- 50
                                in vpatientcompanyname varchar(20), -- 51
                                in vpatientemployeenumber varchar(20), -- 52
                                in vpatientsmoking tinyint, -- 53
                                in vpatientfax varchar(20), -- 54
                                in vpatientcellnumber varchar(20), -- 55
                                in vpatientinfo longtext, -- 56
                                in vpatientcommpref varchar(5), -- 57
                                in vpatienthometel varchar(20), -- 58
                                in vpatientworktel varchar(20), -- 59
                                in vpatientvip tinyint, -- 60
                                in vpatientpacemaker tinyint, -- 61
                                in vbranchcode varchar(50), -- 62
                                in vwardcode varchar(5),  -- 63
                                in vwaiting tinyint, -- 64
                                in vafterhours tinyint, -- 65
                                in vreferringdoctorcode varchar(10), -- 66
                                in vsecondarydoctorcode varchar(10), -- 67
                                in vaccountcomments longtext, -- 68
                                in vmethodofpayment varchar(20), -- 69
                                in vhospitalpatient tinyint, -- 70
                                in vhospitalnumber varchar(10), -- 71
                                in vauthnumber varchar(20), -- 72
                                in vpregnant tinyint, -- 73
                                in vaccountbreastfeeding tinyint, -- 74
                                in vpriority tinyint, -- 75
                                in vpatientstate varchar(20), -- 76
                                in vvatinvoice tinyint, -- 77
                                in vurgent tinyint,
                                in vburncd tinyint,
                                in vnumberofcds integer,
                                in vemailreport tinyint,
                                in vmva tinyint,
                                in viod tinyint,
                                in vdateofinjury date,
                                in vaccountclaimno varchar(20),
                                in vrestrictimages tinyint,
                                in vimagecommpref varchar(20),
                                in vrequiresdespatch tinyint,
                                in vpreviousimages int,
                                in vholdaccount tinyint,
                                in vaccountusername varchar(15),
                                in vlegalentityid tinyint,
                                in vemployerregistrationname varchar(100),
                                in vemployerregistrationnumber varchar(100),
                                in vnoauthrequired tinyint,
                                in vpatientpay tinyint,
                                in vreportonly tinyint,
								in vemployeremail varchar(255),
								in vemployeraddressline1 varchar(50),
								in vemployeraddressline2 varchar(50),
								in vemployeraddressline3 varchar(50),
								in vemployeraddressline4 varchar(50),
								in vemployerpostalcode varchar(10),
                                in vbookid int(11),
                                in vdetailid int(11),
                                in vbookcolor int)
begin
	declare vaccountid integer;
    declare vaccessid integer;
    declare vsaccess varchar(15);
	
	declare vteller integer;    
	declare vmemberteller integer;    
	declare vpatreltomem bigint;
	declare vpv integer;    	
	declare vpc integer;    	
	
	declare vmemadres_postal bigint;
	declare vmemadres_employer bigint;
	declare vmemadres_home bigint;
	declare vmemadres_relative bigint;
	declare vpatientuid varchar(64);
	declare vcounter bigint;
	
	declare vmedaidid bigint;
	declare vsiteid bigint;
	declare vprirefdocid bigint;
	declare vsecrefdocid bigint;
	declare vbranchid bigint;
	declare vpatcondid bigint;
	declare vwardid bigint;
	declare vmopid bigint;
	declare vmedaidplanid bigint;
	declare vold_medaidcode varchar(10);
	declare vold_medaidid bigint;
	declare vold_medaidplanid bigint;
    declare vold_feemedaidid bigint;
	declare vold_feemedaidplanid bigint;
    declare moetfeerecalc integer;
	declare vold_medaidplancode varchar(10);
	declare vold_smedicalaidreference varchar(25);
    declare vtempstatus varchar(5);
	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[PC]:',MSG),1,128);   	
			rollback;
    set @g_transaction_started = 0;
		signal sqlstate '45000' set message_text = MSG;
	 end;
      set autocommit = 0;
   if ((@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
     start transaction;  
     set @g_transaction_started = 1;
   end; else begin
    set @g_transaction_started = @g_transaction_started + 1;
   end; end if;
	 
	drop temporary table if exists tmpresult; 
    create temporary table tmpresult    ( 
		vaccountcode varchar(10),
        iaccessionid bigint,
        iaccountid bigint,
        sAccessionNumber varchar(15),
		imemberid bigint,
		ipatientid  bigint
	) engine=memory;  	 

	if (vaccountcode = '') then
		set vaccountcode = null;
	end if;
     /*call debug('PatientCapture',concat('start for  acc ',vaccountcode));*/
     select count(ipkAccountID) into vteller from accounts where sAccountCode = vaccountcode;
	 

	 select ipkPatientConditionID into vpatcondid from patient_conditions PC where PC.sCode = vpatientstate;
	 select ipkMethodOfPaymentID into vmopid from methods_of_payment mop where mop.sMethodOfPayment = vmethodofpayment;
	 select MAX(ipkReferringDoctorID) into vsecrefdocid from referring_doctors rd where rd.sCode = vsecondarydoctorcode;
	 select MAX(ipkReferringDoctorID) into vprirefdocid from referring_doctors rd where rd.sCode = vreferringdoctorcode;
	 select b.ipkBranchID,ifkSiteID into vbranchid,vsiteid from branches b where b.sBranchCode = vbranchcode;
	 select ipkWardID into vwardid from wards w where w.sCode = vwardcode;
	 select ipkRelationID into vpatreltomem from relations r where r.sCode = vpatientrelationtomember;
	 
	 select ipkMemberAddressTypeID into vmemadres_postal from member_address_type mat where mat.sCode = 'p';
	 select ipkMemberAddressTypeID into vmemadres_home from member_address_type mat where mat.sCode = 'h';
	 select ipkMemberAddressTypeID into vmemadres_relative from member_address_type mat where mat.sCode = 'r';
	 select ipkMemberAddressTypeID into vmemadres_employer from member_address_type mat where mat.sCode = 'e';

     select ipkMedicalAidID into vmedaidid from medical_aid ma where ma.sCode = vmedicalaidcode;
	 select ipkMedicalAidPlanID into vmedaidplanid from medical_aid_plan map where map.sGlobalMedicalAidCode = vmedicalaidplancode;
	 
	 select sGlobalMedicalAidCode,m.sMedicalAidReference into vold_medaidplancode,vold_smedicalaidreference from medical_aid_plan map, members m  where m.ipkMemberID = vmemberid and m.ifkMedicalAidPlanID = map.ipkMedicalAidPlanID;
     select ifkFeeMedicalAidID,ifkFeeMedicalAidPlanID into vold_feemedaidid,vold_feemedaidplanid from accounts a where sAccountCode = vaccountcode;
	 select fs.sFeeStatus into vtempstatus	from accounts a,feeing_statuses fs	where a.sAccountCode = vaccountcode and fs.ipkFeeingStatusID = a.ifkFeeingStatusID;		
     set moetfeerecalc = 0; 
	if (vmemberid = 0) then begin
		set vmemberid = null;
		set vmemberteller = 0;
	end; else begin	
	   select count(ipkAccountID) into vmemberteller from accounts where ifkMemberID = vmemberid; 
	end; end if;
    
    if (vpatientid = 0) then
		set vpatientid = null;
	end if;
    
    if (vmemberid is null and vpatientid is not null) then
		set vmemberid = (select ifkMemberID from patients p where p.ipkPatientID = vpatientid);
	end if;
	
	if (vpatientdateofbirth is null) or (vpatientdateofbirth = '0000/00/00') then begin
	  set vpatientdateofbirth = '1899/01/01';
	end; end if;
	
	if (vmemberdateofbirth is null) or (vmemberdateofbirth = '0000/00/00') then begin
	  set vmemberdateofbirth = '1899/01/01';
	end; end if;
	
	if (vdateofinjury is null) or (vdateofinjury = '0000/00/00') then begin
	  set vdateofinjury = '1899/01/01';
	end; end if;
	
	/*moved below as memberid can change as per above*/
	select ma.sCode,m.ifkMedicalAidID,m.ifkMedicalAidPlanID into vold_medaidcode,vold_medaidid,vold_medaidplanid from medical_aid ma , members m  where m.ipkMemberID = vmemberid and m.ifkMedicalAidID = ma.ipkMedicalAidID;

	if (vmemberid is null) then
		begin

            insert into members(ifkMedicalAidID,
								ifkMedicalAidPlanID,
								dDateEntered,
								dMemberDateOfBirth,
								sVatNo,
								sTitle,
								sInitials,
								sName,
								sSurname,
								bNonSAID,
								sMedicalAidReference,
								sIDNumber,
								sCellphone,
								sNextOfKinTel,
								sFax,
								sEmail,
								sWorkTel,
								sHomeTel)
			values(vmedaidid,
					vmedaidplanid,
					current_timestamp,
                    vmemberdateofbirth,
					vvatno,
					vmembertitle,
					vmemberinitials,
					vmemberfirstname,
                    vmembersurname,
					vmembernonsaid,
					vmedicalaidreference,
					vmemberidnumber,
					vmembercellphone,
					vnextofkintel,
					vmemberfax,
					vmemberemail,
                    vmemberworktel,
                    vmemberhometel);

            set vmemberid = last_insert_id();/*(select @@identity);*/
            update db_stats set iMemberCount = iMemberCount + 1;

			insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
            values(vmemberid,
					vmemadres_postal,
					vmemberpostaladdress1,
					vmemberpostaladdress2,
					vmemberpostaladdress3,
					vmemberpostaladdress4,
					vmemberpostaladdresscode);

            insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
            values(vmemberid,
					vmemadres_home,
					vmemberhomeaddress1,
					vmemberhomeaddress2,
					vmemberhomeaddress3,
					vmemberhomeaddress4,
					vmemberhomeaddresscode);

            insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
            values(vmemberid,
					vmemadres_relative,
					vmembernextofkinaddress1,
					vmembernextofkinaddress2,
					vmembernextofkinaddress3,
					vmembernextofkinaddress4,
					vmembernextofkinaddresscode);
					
            insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
            values(vmemberid,
					vmemadres_employer,vemployeraddressline1,vemployeraddressline2,vemployeraddressline3,vemployeraddressline4,vemployerpostalcode);
					
		end;
	else 
		begin

			if (((vmemberteller > 1) or (vaccountcode is null) ) and ((vmedicalaidcode <> vold_medaidcode) or (vmedicalaidplancode <> vold_medaidplancode) )) then /*or (vold_smedicalaidreference <> vmedicalaidreference) <== will create issue if copy member info used correctly with famlies and nou legal entities*/
				begin

					insert into members(ifkMedicalAidID,
										ifkMedicalAidPlanID,
										dDateEntered,
										dMemberDateOfBirth,
										sVatNo,
										sTitle,
										sInitials,
										sName,
										sSurname,
										bNonSAID,
										sMedicalAidReference,
										sIDNumber,
										sCellphone,
										sNextOfKinTel,
										sFax,
										sEmail,
										sWorkTel,
										sHomeTel)
					values(vmedaidid, 
							vmedaidplanid,
							current_timestamp,
							vmemberdateofbirth,
							vvatno,
							vmembertitle,
							vmemberinitials,
							vmemberfirstname,
							vmembersurname,
							vmembernonsaid,
							vmedicalaidreference,
							vmemberidnumber,
							vmembercellphone,
							vnextofkintel,
							vmemberfax,
							vmemberemail,
							vmemberworktel,
							vmemberhometel);

					set vmemberid = last_insert_id();/*(select @@identity);*/
                    update db_stats set iMemberCount = iMemberCount + 1;

					insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
					values(vmemberid,
							vmemadres_postal,
							vmemberpostaladdress1,
							vmemberpostaladdress2,
							vmemberpostaladdress3,
							vmemberpostaladdress4,
							vmemberpostaladdresscode);

					insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
					values(vmemberid,
							vmemadres_home,
							vmemberhomeaddress1,
							vmemberhomeaddress2,
							vmemberhomeaddress3,
							vmemberhomeaddress4,
							vmemberhomeaddresscode);

					insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
					values(vmemberid,
							vmemadres_relative,
							vmembernextofkinaddress1,
							vmembernextofkinaddress2,
							vmembernextofkinaddress3,
							vmembernextofkinaddress4,
							vmembernextofkinaddresscode);
							
					insert into member_addresses(ifkMemberID, ifkMemberAddressTypeID, sAddressLine1, sAddressLine2, sAddressLine3, sAddressLine4, sPostalCode)
					values(vmemberid,
							vmemadres_employer,vemployeraddressline1,vemployeraddressline2,vemployeraddressline3,vemployeraddressline4,vemployerpostalcode);
							
                end;
			else
				begin

					update members m
						set m.ifkMedicalAidID = vmedaidid,
							m.ifkMedicalAidPlanID = vmedaidplanid,
							m.dMemberDateOfBirth = vmemberdateofbirth,
							m.sVatNo = vvatno,
							m.sTitle = vmembertitle,
							m.sInitials = vmemberinitials,
							m.sName = vmemberfirstname,
							m.sSurname = vmembersurname,
							m.bNonSAID = vmembernonsaid,
							m.sMedicalAidReference = vmedicalaidreference,
							m.sIDNumber = vmemberidnumber,
							m.sCellphone = vmembercellphone,
							m.sNextOfKinTel = vnextofkintel,
							m.sFax = vmemberfax,
							m.sEmail = vmemberemail,
							m.sWorkTel = vmemberworktel,
							m.sHomeTel = vmemberhometel
					where m.ipkMemberID = vmemberid;
					
					update member_addresses
						set sAddressLine1 = vmemberpostaladdress1,
							sAddressLine2 = vmemberpostaladdress2,
							sAddressLine3 = vmemberpostaladdress3,
							sAddressLine4 = vmemberpostaladdress4,
							sPostalCode = vmemberpostaladdresscode
					where ifkMemberID = vmemberid
						and ifkMemberAddressTypeID = vmemadres_postal;

					update member_addresses
						set sAddressLine1 = vmemberhomeaddress1,
							sAddressLine2 = vmemberhomeaddress2,
							sAddressLine3 = vmemberhomeaddress3,
							sAddressLine4 = vmemberhomeaddress4,
							sPostalCode = vmemberhomeaddresscode
					where ifkMemberID = vmemberid
						and ifkMemberAddressTypeID = vmemadres_home;

					update member_addresses
						set sAddressLine1 = vmembernextofkinaddress1,
							sAddressLine2 = vmembernextofkinaddress2,
							sAddressLine3 = vmembernextofkinaddress3,
							sAddressLine4 = vmembernextofkinaddress4,
							sPostalCode = vmembernextofkinaddresscode
					where ifkMemberID = vmemberid
						and ifkMemberAddressTypeID = vmemadres_relative;

					update member_addresses
						set sAddressLine1 = vemployeraddressline1,
							sAddressLine2 = vemployeraddressline2,
							sAddressLine3 = vemployeraddressline3,
							sAddressLine4 = vemployeraddressline4,
							sPostalCode = vemployerpostalcode
					where ifkMemberID = vmemberid
						and ifkMemberAddressTypeID = vmemadres_employer;						
                end;
			end if;
        end;
	end if;

    if (vpatientid is null) then
		begin

			set vcounter = (select MAX(ipkPatientID) from patients p) + 1;

			call createpatientuidproc(vcounter, vpatientuid);

            insert into patients(ifkMemberID, 
								sTitle, 
                                sInitials, 
                                sName, 
                                sSurname, 
                                sIDNumber, 
                                dDateOfBirth, 
                                dDateEntered, 
                                iPDependantNo, 
                                bActive, 
                                bNonSAID, 
                                sAllergies, 
                                sOccupation, 
                                sCompanyName, 
                                bAsthma, 
                                sCellphone, 
                                sSex, 
                                sEmail, 
                                sEmployeeNumber, 
                                sComsPreference, 
                                ifkRelationID,
                                sHomeTel,
                                sWorkTel,
                                bConsent,
                                sUID)
            values (vmemberid, 
					vpatienttitle, 
                    vpatientinitials, 
                    vpatientfirstname, 
                    vpatientsurname, 
                    vpatientidnumber, 
                    vpatientdateofbirth, 
                    current_timestamp, 
                    vpatientdependantno, 
                    1, 
                    vpatientnonsaid, 
                    vpatientallergies, 
                    vpatientoccupation, 
                    vpatientcompanyname, 
                    vpatientasthma, 
                    vpatientcellnumber, 
                    vpatientsex, 
                    vpatientemail, 
                    vpatientemployeenumber, 
                    vpatientcommpref, 
                    (select ipkRelationID from relations r where r.sCode = vpatientrelationtomember),
                    vpatienthometel,
                    vpatientworktel,
                    vpatientconsent,
                    vpatientuid);

            set vpatientid = last_insert_id();/*(select @@identity);*/
            update db_stats set iPatientCount = iPatientCount + 1;

            call capturepatienthistory(vpatientuid, vpatientinfo);
		end;
	else
		begin

            set vpatientuid = (select sUID from patients p where p.ipkPatientID = vpatientid);

            if (vpatientuid is null) then
				begin

					call createpatientuidproc(vpatientid, vpatientuid);
                end;
			end if;

			update patients p
				set p.ifkMemberID = vmemberid,
					p.sTitle = vpatienttitle, 
					p.sInitials = vpatientinitials, 
					p.sName = vpatientfirstname, 
					p.sSurname = vpatientsurname, 
					p.sIDNumber = vpatientidnumber, 
					p.dDateOfBirth = vpatientdateofbirth, 
					p.iPDependantNo = vpatientdependantno, 
					p.bActive = 1, 
					p.bNonSAID = vpatientnonsaid, 
					p.sAllergies = vpatientallergies, 
					p.sOccupation = vpatientoccupation, 
					p.sCompanyName = vpatientcompanyname, 
					p.bAsthma = vpatientasthma, 
					p.sCellphone = vpatientcellnumber, 
					p.sSex = vpatientsex, 
					p.sEmail = vpatientemail, 
					p.sEmployeeNumber = vpatientemployeenumber, 
					p.sFax = vpatientfax, 
					p.sComsPreference = vpatientcommpref, 
					p.ifkRelationID = vpatreltomem,
                    p.sHomeTel = vpatienthometel,
                    p.sWorkTel = vpatientworktel,
                    p.bConsent = vpatientconsent,
                    p.sUID = vpatientuid
			where p.ipkPatientID = vpatientid;

            call capturepatienthistory(vpatientuid, vpatientinfo);
		end;
	end if;

	if (vaccountcode is null) then
		begin

			select concat(p.sPrefix, lpad(cast((coalesce(p.iCounter,0) + 1) as char), 6, '0')) as sAccountCode
			into vaccountcode
			from branches b
			inner join prefix p
				on p.sPrefix = b.sPrefix
			where b.sBranchCode = vbranchcode;

			insert into accounts(ifkMemberID,
								ifkPatientID, 
								sAccountCode, 
                                ifkSiteID,
								ifkBranchID, 
								ifkWardID, 
								bWaiting, 
								bAfterHours, 
								ifkPrimaryReferringDoctorID, 
								ifkSecondaryReferringDoctorID, 
								/*sComment2, */
								ifkMethodOfPaymentID, 
								bHospitalPatient, 
								sHospitalNumber,
                                bNoAuthRequired,
								sAuthorization, 
								bPregnant, 
								ifkPatientConditionID, 
								bVATInvoice,
                                bPatientPay,
                                bReportOnly,
								bUrgent, 
								bBurnCD, 
								iCDCopies, 
								bEMail, 
								bMVA, 
								bWCA, 
								bDespatch, 
								bPreviousImages, 
								bHold, 
								bBreastFeeding,
								sUserName,
								bRestrictImages,
								ifkLegalEntityID,ifkFeeMedicalAidID,ifkFeeMedicalAidPlanID)
			values(vmemberid,
					vpatientid, 
					vaccountcode, 
                    vsiteid, 
					vbranchid, 
					vwardid, 
					vwaiting, 
					vafterhours, 
					vprirefdocid, 
					vsecrefdocid, 
					/*vaccountcomments, */
					vmopid, 
					vhospitalpatient, 
					vhospitalnumber, 
                    vnoauthrequired,
					vauthnumber, 
					vpregnant, 
					vpatcondid, 
					vvatinvoice, 
                    vpatientpay,
                    vreportonly,
					vurgent, 
					vburncd, 
					vnumberofcds, 
					vemailreport, 
					vmva, 
					viod, 
					vrequiresdespatch, 
					vpreviousimages, 
					vholdaccount, 
					vaccountbreastfeeding,
					vaccountusername,
					vrestrictimages,
                    vlegalentityid,vmedaidid,vmedaidplanid);

			set vaccountid =   last_insert_id();/*(select @@identity);*/
			update prefix p
			inner join branches b
				on p.sPrefix = b.sPrefix
				set p.iCounter = ifnull(p.iCounter,0) + 1
			where b.sBranchCode = vbranchcode;

            call accessioncreate(vaccountid,vaccessid,vsaccess);
            if not exists (select ipkVisitID from visit where ifkaccountID = vaccountid and ifkaccessionID = vaccessid) then begin
				insert into visit(ifkaccountID, dExaminationDate, dDateEntered, sUserName,ifkaccessionID)
				values(vaccountid, current_timestamp, current_timestamp, vaccountusername,vaccessid);
            end; end if; 
			
            update db_stats set iVisitCount = iVisitCount + 1;

			insert into account_priorities(ifkaccountID, iPriority)
			values(vaccountid, ifnull(vpriority,0));

            call captureaccountcomment(vaccountcode, vaccountcomments);


            /*if (vemployerregistrationname <> '') then begin*/
                            insert into wca(dDateOfInjury,
											ifkaccountID,
											sOccupation,
											sEmployer,
											sEmployerTel,
											sWCAClaimNumber,
                                            sEmployerRegistrationName,
                                            sEmployerRegistrationNumber,
											sEmail,
											sAddressLine1,
											sAddressLine2,
											sAddressLine3,
											sAddressLine4,
											sPostalCode)
							values(vdateofinjury,
									vaccountid,
									vpatientoccupation,
									vpatientcompanyname,
									vpatientworktel,
									vaccountclaimno,
                                    vemployerregistrationname,
                                    vemployerregistrationnumber,
                                    vemployeremail,
                                    vemployeraddressline1,
                                    vemployeraddressline2,
                                    vemployeraddressline3,
                                    vemployeraddressline4,
                                    vemployerpostalcode);
				/*end;
			end if;*/
            
			/*booking section start*/
            
            if (vbookid <> 0) then
				update bookings
					set iColor = vbookcolor,
						ifkFlowStatusID = 3			/* set booking flow status to arrived*/
				where ipkBookingID = vbookid;  
				
				update booking_details
					set ifkaccountID = vaccountid
				where ipkDetailsID = vdetailid; 
                
                update docimg_documents 
					set sRef_number = vaccountcode
				where sRef_number = (select sBookingCode from bookings where ipkBookingID = vbookid);
                

				/*update booking_details 
					set sAuthNumber = vauthnumber,
					bNoAuthRequired = vnoauthrequired,
					ifkAuthOperatorID = (select ipkOperatorID from operators where sUserName = vaccountusername)
				where ipkDetailsID = vdetailid;*/
                
			if (select sAuthNumber from booking_details where ipkDetailsID = vdetailid) <> (vauthnumber) then
			begin
				update booking_details
					set sAuthNumber = vauthnumber,
					bNoAuthRequired = vnoauthrequired,
					ifkAuthOperatorID = (select ipkOperatorID from operators where sUserName = vaccountusername)
				where ifkaccountID = vaccountid;
            end; end if;
                
            end if;
           
           /*booking section end*/
            
		end;
	else begin
       /*call debug('PatientCapture',concat('account update , acc ',vaccountcode));*/
	           select a.ipkAccountID into vaccountid from accounts a where a.sAccountCode = vaccountcode;
             /*
			 call debug('PatientCapture',concat('vold_medaidid ',vold_medaidid));
			 call debug('PatientCapture',concat('vold_feemedaidid ',vold_feemedaidid));
			 call debug('PatientCapture',concat('vold_medaidplanid ',vold_medaidplanid));
			 call debug('PatientCapture',concat('vold_feemedaidplanid ',vold_feemedaidplanid));
			 call debug('PatientCapture',concat('vmedaidplanid ',vmedaidplanid));
			 call debug('PatientCapture',concat('vmedaidid ',vmedaidid));
	*/
				 if ((vold_medaidid is not null) and (vold_medaidid = vold_feemedaidid) ) then begin
					if (vmedaidid <> vold_feemedaidid)	 then begin
						set vold_feemedaidid =  vmedaidid;
						set vold_feemedaidplanid = vmedaidplanid;
						set moetfeerecalc = 1; 
					end; else begin
					   if ((vold_medaidplanid  is not null) and (vold_medaidplanid  = vold_feemedaidplanid) ) then begin
							if (vmedaidplanid <> vold_feemedaidplanid)	 then begin
								set vold_feemedaidplanid = vmedaidplanid;
								set moetfeerecalc = 1; 
							end; end if;
					   end; end if;
					   if ((vold_medaidplanid is null) and ((vold_feemedaidplanid is null) or (vold_feemedaidplanid = 0))) then begin
						 set vold_feemedaidplanid = null;
					   end; end if;
					end; end if;	
					
				 end; end if;
				 if (vold_feemedaidid is null) then begin
					set vold_feemedaidid =  vmedaidid;
					set moetfeerecalc = 1; 
				 end; end if;
				 if (vold_feemedaidplanid is null) then begin
					set vold_feemedaidplanid =  vmedaidplanid;
					set moetfeerecalc = 1; 
				 end; end if;			 
            
			update accounts
				set ifkMemberID = vmemberid,
					ifkPatientID = vpatientid,
                    ifkSiteID = vsiteid,
					ifkBranchID = vbranchid,
					ifkWardID = vwardid,
					bWaiting = vwaiting,
					bAfterHours = vafterhours,
					ifkPrimaryReferringDoctorID = vprirefdocid,
					ifkSecondaryReferringDoctorID = vsecrefdocid,
					/*sComment2 = vaccountcomments,*/
					ifkMethodOfPaymentID = vmopid,
					bHospitalPatient = vhospitalpatient,
					sHospitalNumber = vhospitalnumber,
                    bNoAuthRequired = vnoauthrequired,
					sAuthorization = vauthnumber,
					bPregnant = vpregnant,
					ifkPatientConditionID = vpatcondid,
					bVATInvoice = vvatinvoice,
                    bPatientPay = vpatientpay,
                    bReportOnly = vreportonly,
					bUrgent = vurgent,
					bBurnCD = vburncd,
					iCDCopies = vnumberofcds,
					bEMail = vemailreport,
					bMVA = vmva,
					bWCA = viod,
					bDespatch = vrequiresdespatch,
					bPreviousImages = vpreviousimages,
					bHold = vholdaccount,
					bBreastFeeding = vaccountbreastfeeding,
					/*sUserName = vaccountusername,*/
					bRestrictImages = vrestrictimages,
                    ifkLegalEntityID = vlegalentityid,
					ifkFeeMedicalAidID = vold_feemedaidid,
					ifkFeeMedicalAidPlanID = vold_feemedaidplanid
			where ipkAccountID = vaccountid;

            /*select sAccountCode, sComment2 from accounts a where a.sAccountCode = vaccountcode;*/
            
			if (select sAuthNumber from booking_details where ipkDetailsID = vdetailid) <> (vauthnumber) then
			begin
				update booking_details
					set sAuthNumber = vauthnumber,
					bNoAuthRequired = vnoauthrequired,
					ifkAuthOperatorID = (select ipkOperatorID from operators where sUserName = vaccountusername)
				where ifkaccountID = vaccountid;
            end; end if;
          
            if (moetfeerecalc = 1) then begin
				if ((vtempstatus = 'r') or (vtempstatus = 'f') or (vtempstatus is null) ) then begin
						call recalcfeelines(vaccountid,vold_feemedaidid,1);
				end; end if;
            end; end if;    

            if exists (select ap.ipkAccountPriorityID from account_priorities ap where ap.ifkaccountID = vaccountid) then begin
                    update account_priorities ap
						set iPriority = ifnull(vpriority, iPriority)
                    where ap.ifkaccountID = vaccountid;
            end; else begin
					insert into account_priorities(ifkaccountID, iPriority)
					values(vaccountid, vpriority);
			end; end if;

            call captureaccountcomment(vaccountcode, vaccountcomments);
            
            /*if (vemployerregistrationname <> '') then begin*/
					if exists (select wca.ipkWCAID from wca wca where wca.ifkaccountID = vaccountid) then begin
							update wca
								set dDateOfInjury = vdateofinjury,
									sOccupation = vpatientoccupation,
									sEmployer = vpatientcompanyname,
									sEmployerTel = vpatientworktel,
									sWCAClaimNumber = vaccountclaimno,
                                    sEmployerRegistrationName = vemployerregistrationname,
                                    sEmployerRegistrationNumber = vemployerregistrationnumber,
									sEmail = vemployeremail,
									sAddressLine1 = vemployeraddressline1,
									sAddressLine2 = vemployeraddressline2,
									sAddressLine3 = vemployeraddressline3,
									sAddressLine4 = vemployeraddressline4,
									sPostalCode = vemployerpostalcode                                   
                            where ifkaccountID = vaccountid;
                    end; else begin
                            insert into wca(dDateOfInjury,
											ifkaccountID,
											sOccupation,
											sEmployer,
											sEmployerTel,
											sWCAClaimNumber,
                                            sEmployerRegistrationName,
                                            sEmployerRegistrationNumber,
											sEmail,
											sAddressLine1,
											sAddressLine2,
											sAddressLine3,
											sAddressLine4,
											sPostalCode)
							values(vdateofinjury,
									vaccountid,
									vpatientoccupation,
									vpatientcompanyname,
									vpatientworktel,
									vaccountclaimno,
                                    vemployerregistrationname,
                                    vemployerregistrationnumber,
                                    vemployeremail,
                                    vemployeraddressline1,
                                    vemployeraddressline2,
                                    vemployeraddressline3,
                                    vemployeraddressline4,
                                    vemployerpostalcode);
					end; end if;
			/*end; end if;*/
            /*call debug('PatientCapture',concat('account update  2, acc ',vaccountcode));*/
            select MAX(ifkaccessionID) into vaccessid from account_exams where ifkaccountID = vaccountid;
            /*call debug('PatientCapture',concat('dicom update , acc ',vaccountcode,', accessid : ',vaccessid));*/
            call updatedicomworklistentry(vaccountcode,vaccessid);
            /*call debug('PatientCapture',concat('hl7 update , acc ',vaccountcode,', accessid : ',vaccessid));*/
            call hl7control(vaccountcode, 'update', vaccountusername,vaccessid);
	end; end if;

	/*call debug('PatientCapture',concat('check PV.PC ELIG , acc ',vaccountcode,', accessid : ',vaccessid));*/
	select iPracticeClaimStatus,iPatientValidationStatus into vpc,vpv from elig_transactions where ifkaccountID = vaccountid;
	/*
    -100 : no sys message - boodskap nie vir sisteem bedoel. blank statusse uit / not meant for system, blank status out
    -1 : error - maak error blokkie / error block

    0 : submitted = maak wolkie, dit is geskep / cloud

    1 : partial success = die vraag teken, header aanvaar, maar met verandering / questionmark header accepted but with changes

    2 : success  = oranja gesig / orange face
    3 : success+ = groen gesig / green face

    6 : waiting = wag vir antwoord
    7 : delayed

    9 : reject = waarskuwings teken, verwerp / alert sign, rejected



    11 : reversal success / clear accounts aa.ifkClaimStatusID
    15 : reversal submitted

	*/
	
	if ((vpc is null) or (vpc in (-1,9)) ) then begin
	   set vteller = 0;
	   select count(ipkAccountExamID) into vteller from account_exams where ifkaccountID = vaccountid;
	   if (vteller > 0) then begin
	     /*call debug('PatientCapture',concat('submit PV , acc ',vaccountcode,', accessid : ',vaccessid));*/
	     call eligsubmitpv(vaccountcode, vaccountusername);
	   end; end if;
	end; end if;
	

     /*call debug('PatientCapture',concat('call log changes , acc ',vaccountcode,', accessid : ',vaccessid));*/
	call log_acountchanges (vaccountid);
	insert into tmpresult(vaccountcode,        iaccessionid ,        iaccountid ,        sAccessionNumber,imemberid,ipatientid ) values (vaccountcode,vaccessid,vaccountid,vsaccess,vmemberid,vpatientid);
	
  if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
    select * from tmpresult;
	
/*    drop temporary table if exists tmpresult;*/
  
end$$

delimiter ;

