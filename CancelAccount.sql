drop procedure if exists `CancelAccount`;

delimiter $$
create definer=`root`@`localhost` procedure `CancelAccount`(in vaccountCODE varchar(10),
								in vuserNAME varchar(15),
                                in vNOTE varchar(500))
begin

	declare vtelw integer;

	update accounts a
	set    	a.ifkCancelledByOperatorsID = (select ipkOperatorID from operators o where o.sUserName = vuserNAME),
            a.bActive = 0,
            a.ifkLockedByOperatorsID = null,
            a.sNote = vNOTE
	where  a.sAccountCode = vaccountCODE;

	update dicom_worklist dwl
	set    ifkDicomStatusID = (select ipkDicomStatusID from dicom_statuses ds where ds.sDicomStatus = 'discontinued')
	where  ifkAccountID = (select ipkAccountID from accounts a where a.sAccountCode = vaccountCODE);

	update operators o
	set    o.ifkCurrentAccountID = null
	where  o.ifkCurrentAccountID = (select ipkAccountID from accounts a where a.sAccountCode = vaccountCODE);

	set vtelw = 0;

	/*update bookings b
		set b.bActive = 0,
			b.ifkoperatorcancelledid = (select ipkOperatorID from operators o where o.sUserName = vuserNAME)
	where  b.ifkAccountID = (select ipkAccountID from accounts a where a.sAccountCode = vaccountCODE);*/

    call RunTriggerCheck('hc', @vtelw);

	if (@vtelw = 1) then
		call HL7AddTask(vaccountCODE, 'cancel', vuserNAME, '',0);
	end if;
end$$
delimiter ;
