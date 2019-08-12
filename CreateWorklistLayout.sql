use `promed`;
drop procedure if exists `CreateWorklistLayout`;

delimiter $$
use `promed`$$
create definer=`development`@`%` procedure `CreateWorklistLayout`(in voperatorid int(11),
  in vworklistid int(11),
  in vlayout blob,
  in vzoom int)
begin
    declare vlayoutid bigint;
    
    select ipkLayoutID into vlayoutid 
    from operator_worklists_layouts 
    where ifkOperatorID = voperatorid 
    and iWorklistID = vworklistid;
    
	if (vlayoutid = 0) then
		set vlayoutid = null;
	end if;   
    
    if (vlayoutid is null) then
		begin
			insert into operator_worklists_layouts(ifkOperatorID, iWorklistID, blLayout, iZoom)
			values(voperatorid, vworklistid, vlayout, vzoom);
		end;
	else
		begin
			update operator_worklists_layouts 
            set blLayout = vlayout,
				iZoom = vzoom
            where ifkOperatorID = voperatorid 
            and iWorklistID = vworklistid; 
		end;
	end if;
    
end$$

delimiter ;

