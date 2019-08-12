use `promed`;
drop procedure if exists `Debtor_AccountAgeEventSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AccountAgeEventSave`(in vaccid bigint,
											   in vageid integer,
											   in vbMemberStatementPrinted smallint,
                                               in vbMedAidStatementPrinted smallint,
                                               in vbFinalNoticePrinted smallint,
                                               in vbHandOverPrinted smallint)
begin
/*
  NOTE if any flag is set to -10 then it will be set to what is currently saved in the db if any, else to 0
  
*/

   declare vtmpbMemberStatementPrinted smallint;
   declare vtmpbMedAidStatementPrinted smallint;
   declare vtmpbFinalNoticePrinted smallint;
   declare vtmpbHandOverPrinted smallint;
   declare veventid integer;
   
  declare done boolean default 0;
 declare MSG varchar(128);
 
 declare continue handler for sqlstate '02000' set done = 1;          
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[daaes]:',MSG),1,128);   	
		rollback;
    set @g_transAction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
 
  set autocommit = 0;
   if ((@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
     start transAction;  
     set @g_transAction_started = 1;
   end; else begin
    set @g_transAction_started = @g_transAction_started + 1;
   end; end if;  
   
     
     select ipkDebtorAccountAgeEventID,bMemberStatementPrinted,bMedAidStatementPrinted,bFinalNoticePrinted,bHandOverPrinted 
        into veventid,vtmpbMemberStatementPrinted,vtmpbMedAidStatementPrinted,vtmpbFinalNoticePrinted,vtmpbHandOverPrinted
     from debtor_account_age_events
     where ifkAccountID = vaccid and ifkAgeID = vageid;
     
     if (vbMemberStatementPrinted <> -10) then begin
         set vtmpbMemberStatementPrinted = vbMemberStatementPrinted;
     end; end if;
     if (vbMedAidStatementPrinted <> -10) then begin
         set vtmpbMedAidStatementPrinted = vbMedAidStatementPrinted;
     end; end if;
     if (vbFinalNoticePrinted <> -10) then begin
         set vtmpbFinalNoticePrinted = vbFinalNoticePrinted;
     end; end if;
     if (vbHandOverPrinted <> -10) then begin
         set vtmpbHandOverPrinted = vbHandOverPrinted;
     end; end if;
     
     if (vtmpbMemberStatementPrinted is null) then begin
        set vtmpbMemberStatementPrinted = 0;
     end; end if;
     if (vtmpbMedAidStatementPrinted is null) then begin
        set vtmpbMedAidStatementPrinted = 0;
     end; end if;
     if (vtmpbFinalNoticePrinted is null) then begin
        set vtmpbFinalNoticePrinted = 0;
     end; end if;
     if (vtmpbHandOverPrinted is null) then begin
        set vtmpbHandOverPrinted = 0;
     end; end if;
     
     if ((veventid is null) or (veventid <= 0)) then begin
                 insert into debtor_account_age_events (ipkDebtorAccountAgeEventID, dDateEntered, ifkAgeID, ifkAccountID, bMemberStatementPrinted, bMedAidStatementPrinted, bFinalNoticePrinted,
							bHandOverPrinted) values
					(0, current_timestamp, vageid, vaccid, vtmpbMemberStatementPrinted, vtmpbMedAidStatementPrinted, vtmpbFinalNoticePrinted,vtmpbHandOverPrinted);
    end; else begin
        update debtor_account_age_events
             set bMemberStatementPrinted = vtmpbMemberStatementPrinted,
				bMedAidStatementPrinted = vtmpbMedAidStatementPrinted,
				bFinalNoticePrinted = vtmpbFinalNoticePrinted,
				bHandOverPrinted = vtmpbHandOverPrinted
				where ipkDebtorAccountAgeEventID = veventid;

    end; end if;
    
if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
  
end$$

delimiter ;

