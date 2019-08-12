USE `promed`;
DROP procedure IF EXISTS `HL7Control`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `HL7Control`(   IN vAccountCode varchar(10), 
                                        IN vReplicationType varchar(10), 
                                        IN vUser varchar(10), IN vAccessionID BIGINT)
BEGIN
	/*

    Integration KEY
	==========
    HL: HL7 Intigasie

    */

    declare vTempCount integer;
    declare vHL7Run smallint;
    declare vExamCount integer;
    declare vStatusNum integer;
    
    declare vAccountID integer;
	    	 declare msg VARCHAR(128);
	 DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[H7C]:',msg),1,128);   	
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

    SET vAccountID = (SELECT ipkAccountID FROM accounts A WHERE A.sAccountCode = vAccountCode);

	SET vHL7Run = 0;

	CALL RunTriggerCheck('HL', @vTriggerCheck);

	if (@vTriggerCheck = 1) then 
		SET vHL7Run = 1;
	END IF;

	SET @vTriggerCheck = 0;

	if ((vHL7Run = 1) and (vAccountID is not null)) then /*HL7  Intigrasie*/
		begin

			select count(AEHL.ipkAccountExamID) 
			into vExamCount
			from account_exams AEHL
			where AEHL.ifkAccountID = vAccountID and AEHL.ifkAccessionID = vAccessionID;

			if (vExamCount > 0) then /*account must have an exam to be valid*/
				begin

					SET vTempCount = 0;

					select count(*)    
					into vTempCount
					from hl7_sending_list h
					where h.sTaskType = 'REGISTER'
						and h.ifkAccountID = vAccountID and h.ifkAccessionID = vAccessionID;

					if (vTempCount = 0) then 
						begin

							CALL HL7AddTask(vAccountCode,'REGISTER',vUser,'',vAccessionID);
						end ;
					end if;
					
					if (vReplicationType = 'REPORT') then 
						begin

							/*Stuur elke keer as hulle stoor kliek*/
							SET @vTriggerCheck = 0;

							CALL RunTriggerCheck('H1',@vTriggerCheck);

							if (@vTriggerCheck = 1) then

								CALL HL7AddTask(vAccountCode,'REPORT',vUser,'',vAccessionID);
							end if;

							/*Stuur NET as verslag geAuth is*/
							SET @vTriggerCheck = 0;

							CALL RunTriggerCheck('H2', @vTriggerCheck);

							if (@vTriggerCheck = 1) then 
								begin

									SET vStatusNum = 0;

									select iStatusNumber 
									into vStatusNum
									from account_report_status ARS 
									where ARS.ifkAccountID = vAccountID and ars.ifkAccessionID = vAccessionID;

									if (vStatusNum = 99) then 

										CALL HL7AddTask(@vAccountCode,'REPORT',vUser,'',vAccessionID);
									end if;
								end;
							end if;
						end; 
					else 
						begin

							CALL HL7AddTask(vAccountCode,'UPDATE',vUser,'',vAccessionID);
						end;
					end if;
				end;
			end if;
		end;
	end if;
    	     if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if; 
END$$

DELIMITER ;

