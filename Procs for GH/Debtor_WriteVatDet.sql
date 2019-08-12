use `promed`;
drop procedure if exists `Debtor_WriteVatDet`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_WriteVatDet`(in v_accountid bigint,in v_statementid bigint,
in v_debtortransactiontype integer,
in v_taxtype integer,
in v_vatdate timestamp,
in v_transactionlinenumber integer,
in v_stransactiondescription varchar(100),
in v_ftransactionamount decimal(18,2),
in v_ftransactionvatamount decimal(18,2),
in v_fvatpercentage decimal(18,2),
in v_bvatcreditnote smallint
)
begin
  declare v_smembersurname varchar(80);
  declare v_smemberinitials varchar(10);
  declare v_bvatinvoice smallint  ;
  
  
  select  m.sSurname ,m.sInitials,a.bVATInvoice into v_smembersurname,v_smemberinitials,v_bvatinvoice from accounts a, members m where a.ifkMemberID = m.ipkMemberID and a.ipkAccountID = v_accountid;
  
   insert into debtor_vat_details (ipkDebtoVatDetID,ifkDebtorTransactionType,ifkTaxType,dVatDate,iTransactionLineNumber,sMemberSurname,sMemberInitials,sTransactionDescription,fTransactionAmount,
								fTransactionVatAmount,fVatPercentage,bVatCreditNote,bVATInvoice,dDateEntered,ifkaccountID,ifkStatementID)
			values
				(0,v_debtortransactiontype,v_taxtype,v_vatdate,v_transactionlinenumber,
				v_smembersurname,v_smemberinitials,v_stransactiondescription,v_ftransactionamount,v_ftransactionvatamount,
				v_fvatpercentage,v_bvatcreditnote,v_bvatinvoice,current_timestamp,v_accountid,v_statementid);

end$$

delimiter ;

