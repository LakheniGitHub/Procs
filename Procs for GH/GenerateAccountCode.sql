USE `promed`;
DROP procedure IF EXISTS `GenerateAccountCode`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`user-pc` PROCEDURE `GenerateAccountCode`(in vBranchCode varchar(3),
										out vAccountCode varchar(10))
BEGIN
    declare vPrefix varchar(2);
declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[GAC]:',MSG),1,128);   	
			rollback;
    set @g_transaction_started = 0;
		signal sqlstate '45000' set message_text = MSG;
	 end;
      set autocommit = 0;
   if ((@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
     start transaction;  
     set @g_transaction_started = 1;
   end; else begin
    set @g_transaction_started = @g_transaction_started + 1;
end; end if;

    
    select b.sPrefix into vPrefix from branches b where b.sBranchCode = vBranchCode;
    
	select concat(p.sPrefix, lpad(cast((coalesce(p.iCounter,0) + 1) as char), 6, '0')) 
			into vAccountCode
			from prefix p
			where p.sPrefix = vPrefix;
            
			update prefix p
				set p.iCounter = ifnull(p.iCounter,0) + 1
			where p.sPrefix = vPrefix;

 if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
end; end if; 
            
END$$

DELIMITER ;

