USE `promed`;
DROP procedure IF EXISTS `tool_createpatientforaccountfromfirstlogentry`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE `tool_createpatientforaccountfromfirstlogentry` (in vAccCode  varchar(10))
BEGIN
declare vpatientid bigint;
declare vpatientuid varchar(64);
declare vaccid bigint;
declare vaccessid bigint;

declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		if (MSG is null) then begin
		  set MSG = '';
		end; end if;
		set MSG = substring(concat('[t_cpfaffle]:',MSG),1,128);   	
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
   select ipkAccountID into vaccid from accounts where sAccountCode = vAccCode;
   
   if ((vaccid > 0) and (vaccid is not null)) then begin
			   
			INSERT INTO patients (ipkPatientID,ifkMemberID,ifkOriginalPatientID,ifkSiteID,sTitle,sInitials,sName,sSurname,
								sIDNumber,dDateOfBirth,dDateEntered,iPDependantNo,bAppointment,sUID,bActive,bNonSAID,bSmoking,
								bVIP,bConsent,bParentConsent,sAllergies,sOccupation,blPatientInfo,sCompanyName,iWeight,bValves,
								bAsthma,bPregnant,bPacemaker,bMetalInHead,bClips,sCellphone,sSex,sLanguage,sEmail,sEmployeeNumber,
								sFax,sComsPreference,ifkRelationID,sHomeTel,sWorkTel,sForceNumber)
								
					(SELECT 0,acl.A_ifkMemberID,0,acl.P_ifkPatientSiteID,acl.P_sTitle,acl.P_sInitials,acl.P_sName,acl.P_sSurname,
			acl.P_sIDNumber,acl.P_dDateOfBirth,acl.P_dDateEntered,acl.P_iPDependantNo,acl.P_bAppointment,'',acl.P_bActive,acl.P_bNonSAID,
			acl.P_bSmoking,acl.P_bVIP,acl.P_bConsent,acl.P_bParentConsent,acl.P_sAllergies,acl.P_sOccupation,
					acl.P_blPatientInfo,acl.P_sCompanyName,acl.P_iWeight,acl.P_bValves,acl.P_bAsthma,acl.P_bPregnant,acl.P_bPacemaker,acl.P_bMetalInHead,
					acl.P_bClips,acl.P_sCellphone,acl.P_sSex,acl.P_sLanguage,acl.P_sEmail,acl.P_sEmployeeNumber,acl.P_sFax,acl.P_sComsPreference,
					acl.P_ifkRelationID,acl.P_sHomeTel,acl.P_sWorkTel,acl.P_sForceNumber
			 FROM promed_logs.account_change_log acl
			where acl.a_saccountcode = vAccCode order by ipkAccountChangeLogID asc limit 1);

			 set vpatientid = last_insert_id();/*(select @@identity);*/
						call createpatientuidproc(vpatientid, vpatientuid);
						update patients  set sUID = vpatientuid,ifkOriginalPatientID = vpatientid  where ipkPatientID = vpatientid;
						
			update accounts set ifkPatientID = 	vpatientid where ipkAccountID = vaccid;		
            select MAX(ifkaccessionID) into vaccessid from account_exams where ifkaccountID = vaccid;
            
            call updatedicomworklistentry(vAccCode,vaccessid);
            
            call hl7control(vAccCode, 'UPDATE', 'GlobalRag',vaccessid);
			
			call Log_AcountChanges(vaccid);
	end; end if;					
            
            
     if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
end; end if; 

END$$

DELIMITER ;

