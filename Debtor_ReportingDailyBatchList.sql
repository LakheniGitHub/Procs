use `promed`;
drop procedure if exists `Debtor_ReportingDailyBatchList`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingDailyBatchList`(in vday date, in vpracid bigint)
begin
  declare vendDate timestamp;
  
  declare vbatchn varchar(20);
  declare vaccCODE varchar(10);
  declare vrctCODE varchar(10);
  declare vaccid bigint;
  declare vbrnchCODE varchar(10);
  declare vsiten varchar(30);
  declare vpracticeid bigint;
  declare vtrnCODE varchar(20);
  declare vamount decimal(18,2);
  declare vsuspenseamount decimal(18,2);
  
  declare vmop varchar(20);
  declare vmoneygivento varchar(30);
  declare vreceiptamount decimal(18,2);
  declare vpayer varchar(30);
  
  
  declare done boolean default 0;
  declare batchcursor cursor for select  dsa.sBatchNumber,a.sAccountCode,a.ipkAccountID,dtt.sTransactionTypeCode,b.sBranchCode,s.sSiteName,s.ifkPracticeInfoID,sum(dsa.fTransActionAmount) ,sum(sss.fAmount) 
									  from accounts a,sites s,debtor_transAction_types dtt,Branches b,debtor_statement_audit dsa,debtor_statements ds left join debtor_suspense_account sss on (sss.ifkRefID = ds.ipkStatementEntryID)
									 where (ds.dUpdateDateTime >= vday and ds.dUpdateDateTime <= vendDate)
									 and a.ipkAccountID = ds.ifkAccountID
									 and a.ifkSiteID = s.ipkSiteID
									 and dtt.ipkDebtorTransActionType = ds.ifkDebtorTransActionType
									 and (dtt.bMoneyMovement = 1 or dtt.bWriteOff = 1)
									  and s.ifkPracticeInfoID = vpracid
									  and a.ifkBranchID = b.ipkBranchID
									  and dsa.ifkAccountID = ds.ifkAccountID 
									  and dsa.iTransActionLINENUMBER = ds.iLINENUMBER
									  and dsa.dDateEntered >= vday and dsa.dDateEntered <= vendDate
									  group by dsa.sBatchNumber,a.sAccountCode,a.ipkAccountID,dtt.sTransactionTypeCode,b.sBranchCode,s.sSiteName,s.ifkPracticeInfoID;
									  

declare receiptcursor cursor  select r.sReceiptCode,mop.sDescription as smop,ds.fTransActionAmount as fAmount,r.sGiveMoneyTo,r.sPaidBy
							from debtor_suspense ds,receipts r ,methods_of_payment mop
							where ds.ifkReceiptID = r.ipkReceiptID
							and mop.ipkMethodOfPaymentID = ds.ifkMethodOfPaymentID
							and ds.ifkAccountID = vaccid            
							and sBatchNumber = vbatchn;
									  
                                        
 declare continue handler for sqlstate '02000' set done = 1;          
    
  drop temporary table if exists batchinfo;	
	create temporary table batchinfo   ( 
		sBatchNumber varchar(20),
		ifkAccountID bigint,
		sAccountCode varchar(10),
		sReceiptCode varchar(10),
		smop varchar(20),
		sBranchCode varchar(10),
		sSiteName varchar(30),
		ifkPracticeInfoID bigint,
		freceiptamount decimal(18,2),
		fsmallbalanceamount decimal(18,2),
		frefundamount decimal(18,2),
		fsuspenseamount decimal(18,2),
		fhandoveramount decimal(18,2),
		sPayer varchar(30),
		smoneygivento varchar(30),
		freceiptamount decimal(18,2),
		fBalance decimal(18,2),
		dtransdate date
		
	) engine=memory;  	
	
	set vendDate = concat(vday,' 23:59:59');
	
 
open batchcursor;                

	get_batch_cursor: loop
			fetch batchcursor into vbatchn,vaccCODE,vaccid,vtrnCODE,vbrnchCODE,vsiten,vpracticeid,vamount,vsuspenseamount;
			if done = 1 then begin
			   leave get_batch_cursor;
			end; end if;	
			open receiptcursor;                
					get_receipt_cursor: loop
							fetch receiptcursor into vrctCODE,vmop,vreceiptamount,vmoneygivento,vpayer;
							if done = 1 then begin
							   leave get_receipt_cursor;
							end; end if;	
							
							set done = 0;
					end loop get_receipt_cursor;
			close receiptcursor;
	
			set done = 0;
	end loop get_batch_cursor;
    close batchcursor;
 


 
 
 
 
end$$

delimiter ;

