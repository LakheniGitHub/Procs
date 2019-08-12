use `promed`;
drop procedure if exists `Quote_Line_Save`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Quote_Line_Save`(in ventryid bigint,
									in  vquteid bigint,
									in  vtarrifcode varchar(10),
									in  vramscode varchar(10),
									in  vlinenumber integer,
									in  vdescription varchar(150),
									in  vlinetype char(1),
									in  vinvoiced smallint,
									in  vmin integer,
									in  vmax integer,
									in  vnappi varchar(10),
									in  vqty integer,
									in  vprice decimal(18,2),
									in  vcustline smallint,
									in  vorigprice  decimal(18,2),
									in  vpercentage  decimal(18,2), 
									in  vsmcode  varchar(10),
									in  vlookupcode varchar(10),
									in  vsmflag integer,
									in  vrate integer
									)
begin
 declare vexist integer;
declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[qls]:',MSG),1,128);   	
		rollback;
    if (MSG is null) then begin
	   set MSG = '[qls]: unknown error';
    end; end if;	
    set @g_transaction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  set autocommit = 0;
   if ((@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
     start transaction;  
     set @g_transaction_started = 1;
   end; else begin
    set @g_transaction_started = @g_transaction_started + 1;
   end; end if; 
   
 select count(*) into vexist from  quote_lines where ipkQuteLineID = ventryid;
 
 if ((vexist is null) or (vexist <= 0)) then begin

      insert into quote_lines (ipkQuteLineID,dtDateEntered,ifkQuoteID,sTarrifCode,sRAMSCode,iLineNumber,sDescription,sLineType,bInvoiced,iMin,
						iMax,sNappi,iQty,fPrice,bCustLine,fOrigPrice,fPercentage,sSMCode,sLookupCode,iSMFlag,iRate)
				values
			(0,current_timestamp,vquteid,vtarrifcode,vramscode,vlinenumber,vdescription,
			vlinetype,vinvoiced,vmin,vmax,vnappi,vqty,vprice,vcustline,vorigprice,vpercentage,vsmcode,
			vlookupcode,vsmflag,vrate);
  end; else begin
		update quote_lines
		set
			sTarrifCode = vtarrifcode,
			sRAMSCode = vramscode,
			iLineNumber = vlinenumber,
			sDescription = vdescription,
			sLineType = vlinetype,
			bInvoiced = vinvoiced,
			iMin = vmin,
			iMax = vmax,
			sNappi = vnappi,
			iQty = vqty,
			fPrice = vprice,
			bCustLine = vcustline,
			fOrigPrice = vorigprice,
			fPercentage = vpercentage,
			sSMCode = vsmcode,
			sLookupCode = vlookupcode,
			iSMFlag = vsmflag,
			iRate = vrate
			where ipkQuteLineID = ventryid;

  
  end; end if;
  

if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  

end$$

delimiter ;

