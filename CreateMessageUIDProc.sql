delimiter $$
create definer=`root`@`localhost` procedure `CreateMessageUIDProc`(in vversionNUMBER integer,
										out vsUID varchar(64))
begin

	declare vdatestring varchar(50);
	declare vrandomstring1 varchar(40);
	declare vrandomstring2 varchar(40);

    set vdatestring = replace(replace(replace(replace(current_timestamp, ':', ''), '.', ''), '-', ''), ' ', '');
    set vrandomstring1 = rand();
    set vrandomstring1 = right(left(vrandomstring1, 6) ,4);
    set vrandomstring2 = rand();
    set vrandomstring2 = right(left(vrandomstring2, 6) ,4);

    set vsUID = concat(vrandomstring1, '.', vrandomstring2, '.', vdatestring);
end$$
delimiter ;
