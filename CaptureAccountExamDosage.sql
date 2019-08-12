delimiter $$
create definer=`root`@`localhost` procedure `CaptureAccountExamDosage`(in vaccountCODE varchar(8),
																	in vexamCODE varchar(10),
                                                                    in vscreentime time,
                                                                    in vradiationdosage decimal(18,2))
begin

	update account_exams ae
    inner join accounts a
		on a.ipkAccountID = ae.ifkAccountID
	inner join exams e
		on e.ipkExamID = ae.ifkExamID
        set ae.tScreenTime = vscreentime,
			ae.fRadiationDosage = vradiationdosage
	where a.sAccountCode = vaccountCODE and e.sExamCode = vexamCODE;

end$$
delimiter ;
