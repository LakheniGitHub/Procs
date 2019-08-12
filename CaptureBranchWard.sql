delimiter $$
create definer=`root`@`localhost` procedure `CaptureBranchWard`(vBranchCODE varchar(10),
															vWARDCODE varchar(10))
begin

	if not exists (select ipkBranchWARDID from Branch_WARDs bw inner join Branches b on b.ipkBranchID = bw.ifkBranchID inner join WARDs w on w.ipkWARDID = bw.ifkWARDID where b.sBranchCode = vBranchCODE and w.sCode = vWARDCODE) then
		begin

			insert into Branch_WARDs(ifkBranchID, ifkWARDID)
            values ((select ipkBranchID from Branches b where b.sBranchCode = vBranchCODE), (select ipkWARDID from WARDs w where w.sCode = vWARDCODE));
        end;
	end if;

end$$
delimiter ;
