USE `promed`;
DROP procedure IF EXISTS `ConsoleGetPastDicoms`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsoleGetPastDicoms`(IN vAccountCode varchar(10), IN vRelatedOnly TINYINT)
BEGIN
declare vPatientID bigint;
declare vAccountID bigint;
declare vExist int;

SELECT ifkPatientID, ipkAccountID INTO vPatientID, vAccountID FROM accounts A WHERE A.sAccountCode = vAccountCode;

DROP TEMPORARY TABLE IF EXISTS tmpPriorList;	
DROP TEMPORARY TABLE IF EXISTS tmpTariffIgnoreList;	
DROP TEMPORARY TABLE IF EXISTS BodyRegions;	

CREATE TEMPORARY TABLE BodyRegions    ( 
	Region varchar(10)
) ENGINE=MEMORY;  	 

CREATE TEMPORARY TABLE tmpTariffIgnoreList    (  
	tariff varchar(10)
) ENGINE=MEMORY;  

insert into tmpTariffIgnoreList (tariff) (select sSMCode from related_prior_exclude);

if (select count(tariff) from tmpTariffIgnoreList) = 0 then
begin  
	insert into tmpTariffIgnoreList (tariff) values ('00092'),('00091'),('00000'),('HEADING');
end; end if;
	 

CREATE TEMPORARY TABLE tmpPriorList (iStudyID bigint,  iAccountID bigint,      
		PatientName varchar(100),
		dDateOfBirth datetime,
		sIDNumber varchar(20),
		sUID varchar(70),
		DWLStudyDescription varchar(100),
		sStudyInstanceUID varchar(70),
		sExamCode varchar(10),
		sAccountCode varchar(10),
		dDateEntered TIMESTAMP NULL DEFAULT NULL,
		sModalityCode varchar(5),
		sHospitalNumber varchar(20),
		sDescription varchar(100),
		dDateCreated TIMESTAMP NULL DEFAULT NULL,
		sSex char(1),
		sDoctorGroup varchar(100),
		sDoctorMedia varchar(20),
		bComplete smallint,
		sBranchCode varchar(10),
		iLineNumber integer,
		ExamName varchar(100),
		sStudyDescription varchar(100),
		Radiologist varchar(100),
		sRAMSCode varchar(10),
		iExamID bigint,
        ifkAccessionID bigint,
        sAccessionNumber varchar(15),
        sICD10Codes varchar(200),dStudyDate TIMESTAMP NULL DEFAULT NULL
) ENGINE=MEMORY;  	 

 if (vRelatedOnly = 1) then begin
		set vExist = 0;
		select count(*) into vExist from fees f where f.ifkAccountID = vAccountID;
        
		if (vExist > 0)  then begin
			  /*There are fee lines, get regions from there.*/
              
				insert into BodyRegions select distinct(sTarrifCode) 
                from fees f 
                where f.ifkAccountID = vAccountID 
                and f.bFeed = 1 
                and (f.sTarrifCode not in (select tariff from tmpTariffIgnoreList ) 
                and char_length(f.sTarrifCode) >= 5);
                
				update BodyRegions set Region = left(Region, 1);
                
		end; else begin
			  /*No fees get regions from the structures*/
              
				insert into BodyRegions select distinct(p.sTarrifCode) 
                from rams_procedure_rates p, account_exams ae, rams_structure_detail rd, exams e
				where ae.ifkAccountID = vAccountID 
                and ae.ifkExamID = e.ipkExamID 
                and e.sExamCode = rd.sRAMSCode 
                and rd.sSMCode = p.sRAMSCode
				and (rd.sSMFlag = 2 or rd.sSMFlag = 1 or rd.sSMFlag = 0) 
				and p.sTarrifCode not in (select tariff from tmpTariffIgnoreList );
                
				update BodyRegions set Region = left(Region, 1);	
				
		end; end if;     

        insert into tmpPriorList (iStudyID,
			iAccountID,PatientName,dDateOfBirth,
			sIDNumber,sUID,dStudyDate,DWLStudyDescription,
			sStudyInstanceUID,sExamCode,sAccountCode,dDateEntered,
			sHospitalNumber,sDescription,dDateCreated,sSex,sDoctorGroup,
			sDoctorMedia ,bComplete,sBranchCode,ExamName,Radiologist,sRAMSCode,
			iExamID,ifkAccessionID,sAccessionNumber,sICD10Codes) 
		select distinct DWL.ipkDicomWorklistID,A.ipkAccountID,
			P.sName as PatientName, 
			P.dDateOfBirth, 
			P.sIDNumber, 
			P.sUID,
			a.dExamDate,
			E.sName as DWLStudyDescription, 
			DWL.sStudyInstanceUID, 
			E.sExamCode, 
			A.sAccountCode,
			AA.dDateEntered,
			DWL.sHospitalNumber,
			W.sDescription, 
			DWL.dDateCreated, 
			DWL.sSex, 
			DWL.sDoctorGroup, 
			DWL.sDoctorMedia, 
			DWL.bComplete,
			B.sBranchCode, 
			E.sName as ExamName,
			IFNULL(CONCAT(O.sFirstNames, ' ', O.sLastName), '') as Radiologist,
			E.sRAMSCode,
			DWL.ifkExamID,
            aa.ipkAccessionID,
            aa.sAccessionNumber,
            (select GROUP_CONCAT(ci.sICD10Code SEPARATOR ', ') from icd_10 ci where ci.ipkICD10ID in (select distinct(aif.ifkICD10ID) from account_fee_icd10 aif where aif.ifkAccountID = A.ipkAccountID))
		from  accounts A, patients P, dicom_worklist DWL, fees F, exams e, modalities MO, wards W, branches B, account_accessions aa, account_exams ae, visit V 
		left join operators O ON O.ipkOperatorID = V.ifkRadiologistOperatorID
		where P.ipkPatientID = A.ifkPatientID 
		and A.ipkAccountID = DWL.ifkAccountID 
		/*and DWL.ifkExamID = E.ipkExamID*/ 
		and MO.ipkModalityID = DWL.ifkModalityID 
		and W.ipkWardID = A.ifkWardID 
		and B.ipkBranchID = A.ifkBranchID
		and V.ifkAccountID = A.ipkAccountID
		and A.bActive = 1
		and v.ifkAccessionID = aa.ipkAccessionID
		and v.ifkAccessionID = dwl.ifkAccessionID
        
		and ae.ifkAccessionID = aa.ipkAccessionID
        and ae.ifkExamID = E.ipkExamID 
        
		and A.bDeleted = 0
		and a.ifkPatientID = vPatientID 
        and F.ifkAccountID =  A.ipkAccountID
		and F.bFeed = 1
        and left(sTarrifCode,1) in (select Region from BodyRegions);
		/*and A.ipkAccountID <>  vAccountID*/
end; else begin

        insert into tmpPriorList (iStudyID,
			iAccountID,
			PatientName,
			dDateOfBirth,
			sIDNumber,
			sUID,
			dStudyDate,
			DWLStudyDescription,
			sStudyInstanceUID,
			sExamCode,
			sAccountCode,
			dDateEntered,
			sHospitalNumber,
			sDescription,
			dDateCreated,
			sSex,
			sDoctorGroup,
			sDoctorMedia,
			bComplete,
			sBranchCode,
			ExamName,
			Radiologist,
			sRAMSCode,
			iExamID,
			ifkAccessionID,
			sAccessionNumber,
			sICD10Codes) 
        select distinct DWL.ipkDicomWorklistID,
			A.ipkAccountID,
			P.sName as PatientName, 
			P.dDateOfBirth, 
			P.sIDNumber, 
			P.sUID,
			a.dExamDate,
			E.sName as DWLStudyDescription, 
			DWL.sStudyInstanceUID, 
			E.sExamCode, 
			A.sAccountCode,
			AA.dDateEntered,
			DWL.sHospitalNumber,
			W.sDescription, 
			DWL.dDateCreated, 
			DWL.sSex, 
			DWL.sDoctorGroup, 
			DWL.sDoctorMedia, 
			DWL.bComplete,
			B.sBranchCode, 
			E.sName as ExamName,
			IFNULL(CONCAT(O.sFirstNames, ' ', O.sLastName), '') as Radiologist,
			E.sRAMSCode,
			DWL.ifkExamID,
			aa.ipkAccessionID,
			aa.sAccessionNumber, 
			(select GROUP_CONCAT(ci.sICD10Code SEPARATOR ', ') from icd_10 ci where ci.ipkICD10ID in (select distinct(aif.ifkICD10ID) from account_fee_icd10 aif where aif.ifkAccountID = A.ipkAccountID))                        
		from  accounts A, patients P, dicom_worklist DWL, exams e, modalities MO, wards W, branches B, account_accessions aa, account_exams ae, visit V  
		left join operators O on O.ipkOperatorID = V.ifkRadiologistOperatorID
		where P.ipkPatientID = A.ifkPatientID 
		and A.ipkAccountID = DWL.ifkAccountID 
		/*and DWL.ifkExamID = E.ipkExamID*/ 
		and MO.ipkModalityID = DWL.ifkModalityID 
		and W.ipkWardID = A.ifkWardID 
		and B.ipkBranchID = A.ifkBranchID
		and V.ifkAccountID = A.ipkAccountID  
		and A.bActive = 1
		and v.ifkAccessionID = aa.ipkAccessionID 
		and v.ifkAccessionID = dwl.ifkAccessionID
        
        and ae.ifkAccessionID = aa.ipkAccessionID
        and ae.ifkExamID = E.ipkExamID 
        
		and A.bDeleted = 0
		and a.ifkPatientID = vPatientID;
		/*and A.ipkAccountID <>  vAccountID*/
end; end if;

update tmpPriorList p, account_exams ae 
set p.iLineNumber = ae.iLineNumber,
p.dDateEntered = p.dDateEntered  
where ae.ifkAccountID = p.iAccountID 
and ae.ifkExamID = p.iExamID; 

update tmpPriorList p 
set p.iLineNumber = 10, 
p.dDateEntered = p.dDateEntered 
where p.iLineNumber is null;

update tmpPriorList p, exams e 
set p.sStudyDescription = e.sName,
p.dDateEntered = p.dDateEntered  
where p.iLineNumber = 10 
and e.ipkExamID = p.iExamID; 

update tmpPriorList p, rams_structure_detail e 
set p.sStudyDescription = e.sDescription,
p.dDateEntered = p.dDateEntered  
where p.iLineNumber <> 10 
and e.sRAMSCode = p.sRAMSCode 
and p.iLineNumber = e.iLineNumber; 

select * from tmpPriorList order by dStudyDate desc;
 
DROP TEMPORARY TABLE IF EXISTS tmpPriorList;
DROP TEMPORARY TABLE IF EXISTS BodyRegions;	

END$$

DELIMITER ;

