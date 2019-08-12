USE `promed`;
DROP procedure IF EXISTS `EligSubmitPV`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EligSubmitPV`(IN vAccountCode varchar(15),
								IN vUserName varchar(50))
begin
	declare vSuccess integer;
	declare vExists integer;
	declare vEligT varchar(2);
	declare vMember integer;
	/*declare vMedPlan varchar(10);*/
	declare vActive integer;
	declare vMsgTypeTo char(1);
    declare vAccountID INTEGER;

	/* On success return 1 , else 0 */
    	    	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[ESPV]:',msg),1,128);   	
			ROLLBACK;
    set @G_transaction_started = 0;
		signal sqlstate '45000' SET MESSAGE_TEXT = msg;
	 END;
      SET autocommit = 0;
   if ((@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
     START TRANSACTION;  
     set @G_transaction_started = 1;
   end; else begin
    set @G_transaction_started = @G_transaction_started + 1;
   end; end if; 
   
	SET vSuccess = 1;
    
	SET vExists = 0;

	select 	ES.ipkEligibilityStatusID, 
			A.ifkMemberID,
            /*MAP.sOptionName,*/
            MAP.bActive,
            MAP.sEligibility,
            MAP.sPV,
            A.ipkAccountID
    into 	vExists,
			vMember,
            /*vMedPlan,*/
            vActive,
            vEligT,
            vMsgTypeTo,
            vAccountID
    from accounts A
    left JOIN elig_statuses ES
		ON ES.ipkEligibilityStatusID = A.ifkEligibilityStatusID
	LEFT JOIN members M
		ON M.ipkMemberID = A.ifkMemberID
	LEFT JOIN medical_aid_plan MAP
		ON MAP.ipkMedicalAidPlanID = M.ifkMedicalAidPlanID
    where A.sAccountCode = vAccountCode;

	if ((vActive = 1) and (vMsgTypeTo = 'Y')) then 
		begin
			/* -- johannes 17 Aug 2016 0 Laat pv herstuur ongeag of voorheen al het
			if ((bestaan = 0) or (bestaan is null) or (bestaan = 102) or (bestaan = 103) or (bestaan = 100) or (bestaan = 106))  then 

			begin*/
           
			if (vEligT = '') then 
					select PC.sElig 
                    from pms_config PC
                    into vEligT;
			end if;
           
			update accounts A
				set A.ifkEligibilityStatusID = 1 
			where A.ipkAccountID = vAccountID;
           
			select count(ipkEligibilityTransationID) 
            into vExists
            from elig_transactions 
				where ifkAccountID = vAccountID;
            
			
            if (vExists = 0) then 
				insert into elig_transactions (ifkAccountID,sPatientValidationUser,dPatientValidationDate,iPatientValidationStatus,sEligibilityType) 
                values (vAccountID,vUserName,CURRENT_TIMESTAMP,0,vEligT);
			else 
				update elig_transactions
					set sPatientValidationUser = vUserName, 
						iPatientValidationStatus = 0, 
                        dPatientValidationDate = CURRENT_TIMESTAMP 
					where ifkAccountID = vAccountID;
			END IF;

			insert into elig_transaction_messages (ifkAccountID,sMessageType,iMessageStatus,dMessageDate,sUserName,sMessage) 
			values (vAccountID,'PV',0,CURRENT_TIMESTAMP,vUserName,'Patient Validationd Submitted');
		end; 
	else 
		SET vSuccess = 0;
	end if;
    	     if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;
  
    SELECT vSuccess;
end$$

DELIMITER ;

