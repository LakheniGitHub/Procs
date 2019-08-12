USE `promed`;
DROP procedure IF EXISTS `Debtor_ReportingPatientTotalsByRadiologist`;

DELIMITER $$
USE `promed`$$
CREATE PROCEDURE `Debtor_ReportingPatientTotalsByRadiologist` (in vDate date,in vPracID bigint)
BEGIN
  /*
    Phase 1 : When more than one radiologist is against a Account, the first one is used and the rest ignored
	
	Phase 2 (not implemented yet) : Split count (1 account devided by number of radiologist who worked on it)
	                                 and amount (same concept) to give more accurate view of number done by radiologist.
  */
  declare vStartDate timestamp;
  declare vEndDate timestamp;
  declare iYear integer;
  declare iMonth integer;
  declare vteller integer;
  
  declare vFirstNames varchar(80);
  declare vLastName varchar(80);
  declare vAccID bigint;
  declare vOpID bigint;
  declare vCount integer;
  declare vAmount decimal(18,2);
  declare vTmpAmount decimal(18,2);
  declare vTmpCount decimal(18,2);
  
  DECLARE done BOOLEAN DEFAULT 0;
  DECLARE OperatorListCurs CURSOR FOR select o.ipkOperatorID, o.sFirstNames,o.sLastName,a.ipkAccountID,count(a.ipkAccountID),sum(a.fFeedTotal)
													from operators o, visit v,accounts a,sites s
													where v.ifkRadiologistOperatorID = o.ipkOperatorID
													and v.ifkAccountID = a.ipkAccountID
													and s.ipkSiteID = a.ifkSiteID
													and s.ifkPracticeInfoID = vPracID
													and a.dDateEntered >= vStartDate
													and a.dDateEntered <= vEndDate
													group by o.ipkOperatorID, o.sFirstNames,o.sLastName,a.ipkAccountID;

  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;           
  
  set iYear  = year(vDate);
  set iMonth = month(vDate);
  set vStartDate = concat(iYear,'-',iMonth,'-01');
  
  set vEndDate = last_day(vDate);
  set vEndDate = TIMESTAMPADD(HOUR,23,vEndDate);
  set vEndDate = TIMESTAMPADD(MINUTE,59,vEndDate);
  set vEndDate = TIMESTAMPADD(SECOND,59,vEndDate);

  drop TEMPORARY TABLE IF EXISTS tmpTotals; 
  CREATE TEMPORARY TABLE IF NOT EXISTS tmpTotals (iOpID bigint,sFirstNames varchar(80),sLastName varchar(80),fAccountCount decimal(18,2),fTotal decimal(18,2))  ENGINE=MEMORY ;

  drop TEMPORARY TABLE IF EXISTS tmpCheck; 
  CREATE TEMPORARY TABLE IF NOT EXISTS tmpCheck (iAccID bigint)  ENGINE=MEMORY ;
  
 OPEN OperatorListCurs;                

	get_OPeratorList_Cursor: LOOP
			FETCH OperatorListCurs INTO vOpID,vFirstNames,vLastName,vAccID,vCount,vAmount;
			IF done = 1 THEN begin
			   LEAVE get_OPeratorList_Cursor;
			end; END IF;		
            set vteller =0;
            SELECT count(*) into vteller
				FROM tmpCheck
				where iAccID = vAccID;
				
		    if (vteller <= 0) then begin
			   insert into tmpCheck(iAccID) values (vAccID);
				set vCount = ifnull(vCount,1);	
				set vAmount = ifnull(vAmount,0);
				/*
				set vTmpCount = 	(1 / vCount);
				set vTmpAmount = 	 (vAmount / vCount);
				*/
				 
				if (vteller <= 0) then begin
				   insert into tmpTotals(iOpID,sFirstNames,sLastName,fAccountCount,fTotal) values (vOpID,vFirstNames,vLastName,vCount,vAmount);
				end; else begin
				   update tmpTotals set fAccountCount = fAccountCount + vCount, fTotal = fTotal + vAmount where iOpID = vOpID;
				end; end if;
			end; end if;
			
			set done = 0;
	END LOOP get_OPeratorList_Cursor;
    CLOSE OperatorListCurs;
    select * from tmpTotals;

END$$

DELIMITER ;

