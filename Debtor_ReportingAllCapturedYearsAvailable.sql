use `promed`;
drop procedure if exists `Debtor_ReportingAllCapturedYearsAvailable`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_ReportingAllCapturedYearsAvailable`()
begin
  declare vMIN timestamp;
  declare vMAX timestamp;
  declare iMINy integer;
  declare iMAXy integer;
  
  drop temporary table if exists tmpyears; 
  create temporary table if not exists tmpyears (vyear integer)  engine=memory ;
  
  select MIN(dDateEntered),MAX(dDateEntered) into vMIN,vMAX from accounts ;
  set iMINy = year(vMIN);
  set iMAXy = year(vMAX);
  
  while iMINy <= iMAXy    do
   insert into tmpyears(vyear) values (iMAXy);
   set iMAXy = iMAXy - 1;
  end while;
  
  select * from tmpyears;
end$$

delimiter ;

