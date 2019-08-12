USE `promed`;
DROP procedure IF EXISTS `DebtorSetAddionalInfo`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE DebtorSetAddionalInfo (in iAccID bigint,in iAgeID integer,in vClosed integer)
BEGIN
  declare iTel integer;
  declare vDateEntered timestamp;
  declare vPracID bigint;
  declare vYear integer;
  declare vMonth integer;
  declare vQuarter  integer;
  
  /*declare iAgeID integer;*/
  
  /*select ipkAgeID into iAgeID from debtor_age_groups where sAgeCode = vAgeCode;*/
 DECLARE done BOOLEAN DEFAULT 0;
   declare msg VARCHAR(128);
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;    
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
	 BEGIN 
	 /*need min mysql 5.6.4 */
		GET DIAGNOSTICS CONDITION 1 msg = MESSAGE_TEXT;
		set msg = substring(concat('[DSAI]:',msg),1,128);   	
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
   
  select a.dDateEntered ,s.ifkPracticeInfoID into vDateEntered,vPracID from accounts a,sites s where a.ipkAccountID = iAccID and a.ifkSiteID = s.ipkSiteID;
  call DebtorPracticeFiscalInfoForDate(vPracID,vDateEntered,vYear,vMonth,vQuarter);
  
  select count(ifkAccountID) into iTel from debtor_additional where ifkAccountID = iAccID;
  
  if (iTel = 0)  then begin
     INSERT INTO debtor_additional (ifkAccountID,ifkAgeID,bClosed,iEnteredFiscalYear,iEnteredFiscalMonth,iEnteredFiscalQuarter) VALUES (iAccID,iAgeID,vClosed,vYear,vMonth,vQuarter);
  end; else begin
     UPDATE debtor_additional SET ifkAgeID = iAgeID,bClosed = vClosed,iEnteredFiscalYear = vYear,iEnteredFiscalMonth = vMonth,iEnteredFiscalQuarter = vQuarter WHERE ifkAccountID = iAccID;

  end; end if;
  
       if ((@G_transaction_started = 1) or  (@G_transaction_started = 0) or (@G_transaction_started is null)) then begin
    commit;
     set @G_transaction_started = 0;
      SET autocommit = 1;
  end; else begin
    set @G_transaction_started = @G_transaction_started - 1;
  end; end if;  

END$$

DELIMITER ;

