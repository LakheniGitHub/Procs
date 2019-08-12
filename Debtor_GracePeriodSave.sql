use `promed`;
drop procedure if exists `Debtor_GracePeriodSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_GracePeriodSave`(in ventryid bigint,
											in vgracevalue integer,
                                            in vdescr varchar(80))
begin
  declare vexisting integer;
  
  select count(*) into vexisting from debtor_graceperiod where ipkDebtorGracePeriodID = ventryid;
  
  if  ((vexisting is null) or (vexisting <= 0)) then begin
    insert into debtor_graceperiod (ipkDebtorGracePeriodID, dDateEntered, iGraceDays, sGraceDescription)
		  values
		   (0,current_timestamp,vgracevalue,vdescr);

  end; else begin
	update debtor_graceperiod
	set
	iGraceDays = vgracevalue,
	sGraceDescription = vdescr
	where ipkDebtorGracePeriodID = ventryid;
  
  end; end if;

end$$

delimiter ;

