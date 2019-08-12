use `promed`;
drop procedure if exists `Debtor_MedicalAidConfigSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MedicalAidConfigSave`(in ventryid bigint,
												in vmedaidid bigint,
                                                in vageid integer,
                                                in vaction varchar(30))
begin

   declare vexist integer;
   select count(*) into vexist from debtor_medical_aid_config where ipkDebtorMedicalAidConfigID = ventryid;
   
   if ((vexist is null) or (vexist <= 0)) then begin
		insert into debtor_medical_aid_config (ipkDebtorMedicalAidConfigID,ifkMedicalAidID,ifkAgeID,sAction)
		 values
			(0,vmedaidid,vageid,vaction);
   
   end; else begin
		   update debtor_medical_aid_config
				set
				ifkMedicalAidID = vmedaidid,
				ifkAgeID = vageid,
				sAction = vaction
				where ipkDebtorMedicalAidConfigID = ventryid;

   end; end if;
   



end$$

delimiter ;

