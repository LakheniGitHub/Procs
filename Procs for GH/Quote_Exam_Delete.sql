use `promed`;
drop procedure if exists `Quote_Exam_Delete`;

delimiter $$
use `promed`$$
create procedure `Quote_Exam_Delete` (in vquiteid bigint,
									  in vexamid bigint)
begin
declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[qed]:',MSG),1,128);   	
		rollback;
    set @g_transaction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  delete from quote_exams where ifkQuoteID  = vquiteid and ifkExamID = vexamid;
if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
end$$

delimiter ;

