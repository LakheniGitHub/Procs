delimiter $$
create definer=`root`@`localhost` procedure `CheckAssignedAccount`(in vaccountCODE varchar(10))
begin

    select u.NAME
    from users u 
	left join operators o
		on o.sOperatorCode = u.sOperatorCode
	left join accounts a
		on o.ifkCurrentAccountID = a.ipkAccountID
	left join operator_accounts oa
		on oa.sCode = u.sOperatorCode
	left join accounts a2
		on a2.ipkAccountID = oa.ifkAccountID
    where a.sAccountCode = vaccountCODE or a2.sAccountCode = vaccountCODE;
end$$
delimiter ;
