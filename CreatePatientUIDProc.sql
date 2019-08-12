use `promed`;
drop procedure if exists `CreatePatientUIDProc`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CreatePatientUIDProc`(in vpatientNUMBER varchar(50),
									out puid varchar(64))
begin
	declare vdatestring varchar(50);
	declare vrandomstring1 varchar(40);
	declare vrandomNUMBER1 bigint;
	declare vrandomstring2 varchar(40);
	declare vrandomNUMBER2 bigint;
	declare vprefixNUMBER varchar(30);
    set autocommit = 0;
    
    set vdatestring = replace(replace(replace(replace(current_timestamp, ':', ''), '.', ''), '-', ''), ' ', '');
    set vdatestring = left(vdatestring, length(vdatestring)-5);
    set vrandomstring1 = rand();
    set vrandomstring1 = right(left(vrandomstring1, 6) ,4);
	set vrandomNUMBER1 =  vrandomstring1;
    set vrandomstring2 = rand();
    set vrandomstring2 = right(left(vrandomstring2, 6) ,4);
	set vrandomNUMBER2 =  vrandomstring2;
    set vpatientNUMBER = trim(vpatientNUMBER);

    set puid = concat(vpatientNUMBER, '.', vrandomNUMBER1, '.', vrandomNUMBER2, '.', vdatestring);
											 
 if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;	
end$$

delimiter ;

