use `promed`;
drop procedure if exists `GenGetFeePrice`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `GenGetFeePrice`(in vsmflag integer,
                in vrate integer,
                in vsmcode varchar(10),
                in vlookupcode char(10),
                in vmedaid varchar(5),
				in vmedaidid bigint,
                in vmedaidplanid bigint,
                in vqty integer,
				in vtargetdate date,
				out vprice float,
				out vtarrifcode varchar(10),
				out vafterhours varchar(1),
				out vfilm float,
				out vpercind varchar(1))
begin

	declare vperc float;
    declare done integer;
    declare MSG varchar(128);
/*vir main loop nie as einde van dataset sien as die een niks terugbring */    
     declare continue handler for sqlstate '02000' set done=1;
	/* on success return 1 , else 0 */
    	    	 
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[ggfp]:',MSG),1,128);   	
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
   
	set vafterhours = 'n';
	set vpercind = null;
	set vfilm = 0.0;

/*	//no need as the IF directly below it will overwrite it.
if (vsmflag = 3) then 
		begin
    
			select  rsl.fServiceValue, 
					rsl.sTarrifCode, 
                    rsl.sAfterHours, 
                    rsl.iFilm, 
                    rsl.sPercentageInd
			into    vperc, 
					vtarrifcode, 
                    vafterhours, 
                    vfilm, 
                    vpercind
			from   rams_procedure_rates rsl
			where  rsl.sRAMSCode = vsmcode
				and rsl.iRateCode = vrate  and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));

			if (vpercind = 'p') then 
				begin
      
					set vperc = vperc /  100.0;
      
					select rsl.fServiceValue
					into   vprice
					from   rams_procedure_rates rsl
					where  rsl.sRAMSCode = vlookupcode
						and    rsl.iRateCode = vrate  and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));

					set vprice = vprice * vperc / 100;
				end;
			end if;
  
		end;
	end if;
  */  
	if ((vsmflag = 4)  or (vsmflag = 3)) then begin
			call gengetmaterialprice(vsmcode,vmedaidid,vmedaidplanid,vqty,vtargetdate,vprice,vtarrifcode);
	end ;	else if ((vsmflag = 1) or (vsmflag = 2))  then begin
    
				select rsl.fServiceValue, rsl.sTarrifCode, rsl.sAfterHours, rsl.iFilm, rsl.sPercentageInd
				into   vprice, vtarrifcode, vafterhours, vfilm, vpercind
				from   rams_procedure_rates rsl
				where  rsl.sRAMSCode = vsmcode
					and    rsl.iRateCode = vrate  and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
               
               set vprice = vprice/100;    
			end;end if;
	end if;
    
	if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
    
	/*select vprice, vtarrifcode, vafterhours,vfilm,vpercind;*/
end$$

delimiter ;

