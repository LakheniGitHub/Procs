use `promed`;
drop procedure if exists `RunTriggerCheckTrns`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `RunTriggerCheckTrns`(  in triggerkey varchar(3),
                                    out triggervalue tinyint)
begin
   
       	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[rtc]:',MSG),1,128);   	
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
   
    select bRunTrigger 
    into triggervalue
    from site_options 
    where sTriggerKey = triggerkey;
    
    	if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
   
end$$

delimiter ;

