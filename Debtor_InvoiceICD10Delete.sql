use `promed`;
drop procedure if exists `Debtor_InvoiceICD10Delete`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_InvoiceICD10Delete`(in v_icd10id bigint)
begin
  delete from debtor_statement_icd10 where ipkAccountStatementICD10ID = v_icd10id;
end$$

delimiter ;

