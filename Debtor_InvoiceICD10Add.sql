use `promed`;
drop procedure if exists `Debtor_InvoiceICD10Add`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_InvoiceICD10Add`(in v_statementlineid bigint,in vicd10code varchar(10),
																	v_daggercode varchar(10),in v_captureid bigint,in v_addtoallstatementlines smallint)
begin

  declare v_accid bigint;
  declare v_starrifcode varchar(10);
  declare v_ilinenumber integer;
  declare v_lcount integer;
  declare v_icd10id bigint;
  
  select ifkaccountID,sTarrifCode,iLineNumber into v_accid,v_starrifcode,v_ilinenumber from debtor_statements where ipkStatementEntryID = v_statementlineid;
  select ifnull(ipkICD10ID,-1) into v_icd10id from icd_10 i where i.sICD10Code = vicd10code;
  
	if (v_icd10id < 0) then begin
			insert into icd_10(sICD10Code, bCustom) values (vicd10code, 1);
            select ifnull(ipkICD10ID,-1) into v_icd10id from icd_10 i where i.sICD10Code = vicd10code;
	end; end if;
    
    
   if (v_addtoallstatementlines = 0 ) then begin
	 
	 select ifnull(MAX(iLineNumber),0) into v_lcount from debtor_statement_icd10 where ifkaccountID = v_accid and iStatementLineNumber =v_ilinenumber; 
	  set v_lcount = v_lcount + 1;
   
                                                                
     insert into debtor_statement_icd10 (ifkaccountID,sTarrifCode,sDaggerCode,
													iStatementLineNumber,iLineNumber,ifkOperatorID,ifkICD10ID) 
													values 
													(v_accid,v_starrifcode,v_daggercode,v_ilinenumber,v_lcount,v_captureid,v_icd10id);
                                                    
   end; else begin
	  insert into debtor_statement_icd10 (ifkaccountID,sTarrifCode,sDaggerCode,
													iStatementLineNumber,iLineNumber,ifkOperatorID,ifkICD10ID) 
													select v_accid,s.sTarrifCode,v_daggercode,s.iLineNumber,-1,v_captureid,v_icd10id 
															from debtor_statements s,debtor_transaction_types dt 
                                                            where s.ifkDebtorTransactionType = dt.ipkDebtorTransactionType 
																and dt.sShortCode = 'f' 
                                                                and  s.ifkaccountID = v_accid;
                                                                 
							 update debtor_statement_icd10 od
						inner join 
						(
							 select ifkaccountID,iStatementLineNumber, count(iLineNumber)  as hoevlyn
							 from debtor_statement_icd10
							 group by ifkaccountID,iStatementLineNumber
						) og on od.ifkaccountID = og.ifkaccountID and od.iStatementLineNumber = og.iStatementLineNumber
						set od.iLineNumber = og.hoevlyn
						where od.ifkaccountID = v_accid and od.iLineNumber = -1;

     /*update debtor_statement_icd10 set iLineNumber = count(iLineNumber) where ifkaccountID = v_accid and iLineNumber = -1 and;*/
   end; end if;
end$$

delimiter ;

