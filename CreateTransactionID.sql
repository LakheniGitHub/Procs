delimiter $$
create definer=`root`@`localhost` procedure `CreateTransactionID`()
begin
	declare vCODE varchar(20);
	declare vstoredDate integer;
	declare vBranchCODE varchar(3); /* m6 */
	declare vdatestr varchar(8); /* 20061212 */
	declare vpaddedinteger varchar(10); /* 00001 */
	declare vgenvalue integer;
    
    select itransActioncounter
    from stock_counters
    into vstoredDate;
    
    if (vstoredDate <> current_timestamp) then
        update stock_counters
        set itransActioncounter = current_timestamp;
    end if;
    
    select s.sSiteName
    from pms_config PC
    inner join sites s
		on s.ipkSiteID = PC.ifkSiteID
    into vBranchCODE;
    
    set vdatestr = current_timestamp;
    set vgenvalue = gen_id(trans_id_generator, 1);
    set vpaddedinteger = lpad(gen_value, 10, '0');
    
    set vCODE = concat(vBranchCODE,vdatestr,vpaddedinteger);
    
    select vCODE;
end$$
delimiter ;
