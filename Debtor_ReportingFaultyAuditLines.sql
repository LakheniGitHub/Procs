use `promed`;
drop procedure if exists `Debtor_ReportingFaultyAuditLines`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingFaultyAuditLines`() 
begin
/*
  this checks the whole db for all data for any LINEs that breaks fixed rules. for example fee LINEs with a amount > 0 but no fee LINEs is the first that needs to be checked and returned
  
*/
   declare tvaccid bigint;
   declare       tvauditLINEid bigint;
        declare tvtransactintype varchar(10);
         declare tventeredDate timestamp;
		declare tvLINEdesc varchar(100);
		declare tvamount decimal(18,2);
declare 		tvfault varchar(30);
declare tvaccCODE varchar(10);

	declare done boolean default 0;
	
	
  declare faultamountwithoutvatcurs cursor for select dsa.ifkAccountID,dsa.ipkStatementAuditID,dtt.sTransactionTypeCode,dsa.dDateEntered,dsa.sTransactionDescription,dsa.fTransActionAmount,'no vat calced',a.sAccountCode
													 from debtor_statement_audit dsa,debtor_transAction_types dtt,accounts a
													where dsa.fTransActionAmount > 0.03
													and dsa.fVatAmount = 0
													and dsa.ifkDebtorTransActionType = dtt.ipkDebtorTransActionType
													and dtt.sTransactionTypeCode = 'feeadj'
													and a.ipkAccountID = dsa.ifkAccountID;

                                        
 declare continue handler for sqlstate '02000' set done = 1;  
 
  	drop temporary table if exists tmpresult; 
    create temporary table tmpresult    ( 
		 vaccid bigint,
         vauditLINEid bigint,
        vtransactintype varchar(10),
         venteredDate timestamp,
		vLINEdesc varchar(100),
		vamount decimal(18,2), vfault varchar(30),vaccCODE varchar(10)
	) engine=memory; 
 
set done = 0; 
 open faultamountwithoutvatcurs;                

	get_amouintwithoutvat_cursor: loop
			fetch faultamountwithoutvatcurs into tvaccid,tvauditLINEid,tvtransactintype,tventeredDate,tvLINEdesc,tvamount,tvfault,tvaccCODE;
			if done = 1 then begin
			   leave get_amouintwithoutvat_cursor;
			end; end if;		
            insert into tmpresult(vaccCODE,vtransactintype,venteredDate,vLINEdesc,vamount,vfault,vaccid,vauditLINEid) 
			  values (tvaccCODE,tvtransactintype,tventeredDate,tvLINEdesc,tvamount,tvfault,tvaccid,tvauditLINEid);
           
			  set done = 0;
	end loop get_amouintwithoutvat_cursor;
    close faultamountwithoutvatcurs;
	
	select * from tmpresult;
	
  
  
end$$

delimiter ;

