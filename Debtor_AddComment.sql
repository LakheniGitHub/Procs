use `promed`;
drop procedure if exists `Debtor_AddComment`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AddComment`(in sComment text,in vaccid bigint, in vcaptureby bigint,
											in v_addDate timestamp)
begin
	     insert into debtor_comments 
           (ipkDebtorCommentID,sComment,dDateEntered,ifkAccountID,ifkCapturedBy) 
           values
           
           (0,sComment,v_addDate,vaccid,vcaptureby);
           
end$$

delimiter ;

