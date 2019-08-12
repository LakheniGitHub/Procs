use `promed`;
drop procedure if exists `Debtor_MedicalAidConfigDefaultSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MedicalAidConfigDefaultSave`(in vientryid bigint,
													   in viageid integer,
                                                       in vsAction varchar(30))
begin
  declare vexist integer;
  
  select count(*) into vexist from debtor_medical_aid_config_defaults where ipkMedicalAidConfigDefaultID = vientryid;
  
  if ((vexist is null) or (vexist <= 0)) then begin
		insert into debtor_medical_aid_config_defaults (ipkMedicalAidConfigDefaultID,dDateEntered,ifkAgeID,sAction)
		  values
		(0,current_timestamp,viageid,vsAction);
  
  end; else begin
			update debtor_medical_aid_config_defaults
			set
			ifkAgeID = viageid,
			sAction = vsAction
			where ipkMedicalAidConfigDefaultID = vientryid;

  end; end if;
end$$

delimiter ;

