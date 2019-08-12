use `promed`;
drop procedure if exists `ConPacsWebProfile`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `ConPacsWebProfile`(vaccountCODE varchar(10))
begin

	declare vsite varchar(20);
  
	if ((vaccountCODE is null) or (vaccountCODE = '')) then
		begin
  
			select 	p.sWebServerURL, 
					p.sCentralWebserverURL, 
                    p.sWebUser, 
                    p.sWebPass, 
                    p.sAETITLE, 
                    p.iAEPort 
			from pacs_ae_profile p
			where p.bIsArchive = 2
				and p.bEnabled = 1;
		end ;
	else
		begin
			select s.sSiteName
            into vsite
			from accounts a
            inner join sites s
				on s.ipkSiteID = a.ifkSiteID
			where a.sAccountCode = vaccountCODE;

			select 	p.sWebServerURL, 
					p.sCentralWebserverURL, 
					p.sWebUser, 
                    p.sWebPass, 
                    p.sAETITLE, 
                    p.iAEPort
			from pacs_ae_profile p
			inner join pacs_Branch_link pb
				on pb.ifkPacsAEProfileID = p.ipkPacsAEProfile
			inner join Branches b
				on b.ipkBranchID = pb.ifkBranchID
			inner join	accounts a
				on a.ifkBranchID = b.ipkBranchID
			where a.sAccountCode = vaccountCODE
				and p.bEnabled = 1;
		end;
	end if;
end$$

delimiter ;

