use `promed`;
drop procedure if exists `TitlesDelete`;

delimiter $$
use `promed`$$
create procedure `TitlesDelete` (in eventid bigint)
begin
  delete   from titles where ipkTitleID = eventid;
  call tableupdated('titles');	

end$$

delimiter ;

