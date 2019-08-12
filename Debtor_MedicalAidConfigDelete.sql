use `promed`;
drop procedure if exists `Debtor_MedicalAidConfigDelete`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MedicalAidConfigDelete`(in ventryid bigint)
begin
     delete from debtor_medical_aid_config where ipkDebtorMedicalAidConfigID = ventryid;
end$$

delimiter ;

