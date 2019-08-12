use `promed`;
drop procedure if exists `Debtor_MedicalAidConfigDefaultsApplyToAll`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MedicalAidConfigDefaultsApplyToAll`()
begin
  /*
    this will apply the current defaults to all medical aids that does not currently
    have any medical aid defaults setup against them
  */
    
 declare vmedaid bigint;
 	
  declare done boolean default 0;
  declare medaiddefaultscur cursor for select ipkMedicalAidID  from medical_aid where ipkMedicalAidID not in (select distinct(ifkMedicalAidID) from debtor_medical_aid_config);
                                        
 declare continue handler for sqlstate '02000' set done = 1;          
    
 open medaiddefaultscur;                

	get_defaults_cursor: loop
			fetch medaiddefaultscur into vmedaid;
			if done = 1 then begin
			   leave get_defaults_cursor;
			end; end if;	
            
            insert into debtor_medical_aid_config (ipkDebtorMedicalAidConfigID,ifkMedicalAidID,ifkAgeID,sAction) select 0,vmedaid,ifkAgeID,sAction from debtor_medical_aid_config_defaults;
            
			set done = 0;
	end loop get_defaults_cursor;
    close medaiddefaultscur;
    
end$$

delimiter ;

