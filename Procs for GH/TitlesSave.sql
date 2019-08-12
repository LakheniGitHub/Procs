use `promed`;
drop procedure if exists `TitlesSave`;

delimiter $$
use `promed`$$
create procedure `TitlesSave` (in eventid bigint,
							   in vtitle varchar(10),
                               in vsex char(1),
                               in vlanguage char(1))
begin

  declare vexist integer;
  
  select count(*) into vexist from titles where ipkTitleID = eventid;
  
  if ((vexist is null) or (vexist <= 0)) then begin
    insert into titles (ipkTitleID,sTitle,sSex,sLanguage)
      values
     (0,vtitle,vsex,vlanguage);

  end; else begin
	update titles
		set
		sTitle = vtitle,
		sSex = vsex,
		sLanguage = vlanguage
		where ipkTitleID = eventid;

  end; end if;
  call tableupdated('titles');	

end$$

delimiter ;

