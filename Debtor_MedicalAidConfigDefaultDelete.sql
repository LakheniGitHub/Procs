use `promed`;
drop procedure if exists `Debtor_MedicalAidConfigDefaultDelete`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MedicalAidConfigDefaultDelete`(in ventryid bigint)
begin
  delete from debtor_medical_aid_config_defaults where ipkMedicalAidConfigDefaultID = ventryid;
end$$

delimiter ;

