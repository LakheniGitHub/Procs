create definer=`root`@`localhost` procedure `CreateFeeLines`(in vaccountCODE varchar(10),
													in vfeetype integer,
													in vspecialPRICE decimal(18,2),
													in vfactor decimal(18,2),
													in vuserNAME varchar(255))
begin

	call `promed`.`GenCreateFees`(vaccountCODE,vfeetype,vspecialPRICE,vfactor, vuserNAME);
end
