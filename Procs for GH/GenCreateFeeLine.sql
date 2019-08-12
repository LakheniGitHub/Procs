use `promed`;
drop procedure if exists `GenCreateFeeLine`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `GenCreateFeeLine`(in vaccountcode varchar(8),
									in vvisit integer,
									in vref integer,
									in vline integer,
									in vsequence integer,
									in vdescription varchar(100),
									in vquantity integer,
									in vprice float,
									in vmin integer,
									in vmax integer,
									in vfeed integer,
									in vmandatory varchar(1),
									in vstructureline integer,
									in vtarrifcode varchar(10),
									in vdepartment integer,
									in vsmflag integer,
									in vlinedate timestamp,
									in vusername varchar(255),
									in vsmcode varchar(10),
									in vstruccode varchar(10),
									in vvatfactor float,
									in vaddvat integer,
									in vfactor float,
									in vfeetype integer,
                                    in vcommentline tinyint)
begin
	declare vmcp varchar(2);
	declare vcostprice float;
	declare vaccountid integer;
    declare vvatamount decimal(18,2);
/* on success return 1 , else 0 */
    	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[gcfl]:',MSG),1,128);   	
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
   
    set vcommentline = ifnull(vcommentline,0);

	/****************************************************************************/
	/*                                                                          */
	/* please remember:                                                         */
	/*     vprice is original value and COST is calculated from this             */
	/*     COST is for display purpouse                                         */
	/*                                                                          */
	/*		1 = normal 															*/
	/*		2 = after hours														*/	
	/*		3 = special															*/	
	/*		4 = reduced															*/
	/*		5 = report only														*/
	/*		6 = custom normal													*/
	/*		7 = 50% after hours													*/

	/****************************************************************************/

	if (vfeed = 0) then 
		begin
			if ((vmandatory = 'u') or (vmandatory = 'r') or (vmandatory = 's'))   then 
				begin
					set vfeed = 1;
				end;
			end if;
		end;
	end if;

	set vmcp = '';
	
    if ((vsmflag = 1) or (vsmflag = 2)) then 
		begin
			set vmcp = 'p';
			/*    vquantity = 1;*/
			set vmin = 1;
			/*    vmax = 1;*/
		end; 
    else 
		if ((vsmflag = 3) or (vsmflag = 0))  then 
			begin
				set vmcp = 'm';
			end;
		end if;
	end if;
    
	if (vsmflag = 4)   then 
		begin
			set vmcp = 'c';
		end;
	end if;

	if ((vmax is null) or (vmax < 1))  then 
		begin
			set vmax = 1; /* make sure that MAX has a valid value */
		end;
	end if;

	if ((vquantity is null) or (vquantity < 1))  then 
		begin
			set vquantity = 1;
		end;
	end if;

	if ((vfeetype = 1) or (vfeetype = 6) or (vfeetype = 3) ) then 
		begin
			/* vfeetype = normal or custom_normal */
			set vcostprice = (vprice  * vfactor)  * vquantity;
		end;
	else 
		begin
			if (vfactor <= 1) then 				begin
   				    if (vfactor = 0) then 						begin
							set vcostprice = 0;
						end;
					else 

						/*set vcostprice = (vprice - (vprice  * vfactor))  * vquantity;*/
                        set vcostprice = (vprice  * vfactor)  * vquantity;
					end if;
				end;
			else 
				begin
                            set vcostprice = (vprice  * vfactor)  * vquantity;
				end;
			end if;
		end;
	end if;
	/*
	if ((vsmflag = 1) or (vsmflag = 2))  then begin
	vprice = vcostprice; /* this is for the calculation in viking */
	/*  end*/
    set vvatamount = 0.0;
    if (vcostprice <> 0.0) then begin
		if (vaddvat = 1) then begin
				
				/* as vcostprice could still be 0, we need to use vprice */
				/*    vcostprice = vprice * vvatfactor; */
				set vcostprice = vcostprice * vvatfactor;
				set vvatamount = ( vcostprice * vvatfactor) - vcostprice ;
		end; else begin
			   set vvatamount = vcostprice - ( vcostprice / vvatfactor); 
		end; end if;
     end; end if;   

	if (vline = -100) then 
		begin
			
            /*moet maks nommer vat as nuwe nommer vir lyn*/
			select MAX(f.iFeeLine)
			from   fees f
			inner join accounts a
				on a.ipkAccountID = f.ifkaccountID
			where  a.sAccountCode = vaccountcode
			and    f.ifkVisitID = vvisit
			into   vline;

			set vline = vline + 10;
		end;
	end if;
    
    select ipkAccountID
    into vaccountid
    from accounts a
	where a.sAccountCode = vaccountcode;

	insert into fees (ifkaccountID, ifkVisitID, iReference, iFeeLine, iSequence, sDescription, iQuantity, fCost, fUnitPrice, 
					iMinimum, iMaximum, bFeed, sMandatory, iStructureLine, sTarrifCode, ifkDepartmentID, sSMFlag, dLineDate, 
                    sPromedLoginName, sMCPIND, sSMCode, sStrucCode, bCommentLine,fVATAmount)
	values (vaccountid, vvisit, vref, vline, vsequence, vdescription, vquantity, vcostprice, ((vprice) ), vmin, vmax, 
			vfeed, vmandatory, vstructureline, vtarrifcode, vdepartment, vsmflag, vlinedate, vusername, 
            vmcp, vsmcode, vstruccode, vcommentline,vvatamount);
	if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;            
end$$

delimiter ;

