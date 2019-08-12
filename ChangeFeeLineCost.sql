use `promed`;
drop procedure if exists `ChangeFeeLineCost`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `ChangeFeeLineCost`(in vaccountid int,
																in vfeeid integer,
                                                                in vquantity int,
                                                                in vDESCRIPTION varchar(255),
                                                                in vFEED tinyint,
                                                                in vCOST decimal(18,2),
                                                                in vfeetype integer,
																in vfactor decimal(18,2))
begin
	/*		1 = normal 															*/
	/*		2 = after hours														*/	
	/*		3 = special															*/	
	/*		4 = reduced															*/
	/*		5 = report only														*/
	/*		6 = custom normal													*/
	/*		7 = 50% after hours													*/
    declare vvatmultiplier decimal(18,2);
	declare vaddvat integer;
    declare voldQTY integer;
    declare vsmflag integer;
    declare vMANDATORY varchar(1);
	declare vlfactor decimal(18,2);
    declare vPRICEoneandahalf decimal(18,2);
    declare vPRICE decimal(18,2);
    declare vvatamount decimal(18,2);

    select vf.fVATMultiplication, vf.bAddVAT
    from   vat_factor vf
    into   vvatmultiplier, vaddvat;
    
    select fUnitPRICE,sMandatory,iQuantity,sSMFlag into vPRICE,vMANDATORY,voldQTY,vsmflag from fees where ipkFeeID = vfeeid;
    
    if (vFEED = 0) then 
		begin
			if ((vMANDATORY = 'u') or (vMANDATORY = 'r') or (vMANDATORY = 's'))   then 
				begin
					set vFEED = 1;
				end;
			end if;
		end;
	end if;
    
    if (voldQTY <> vquantity) then begin
			set vFEED = 1;
		end;
    end if;
    set vlfactor = vfactor;
    if (vfeetype = 3) /*special one fee PRICE*/	then begin
								set vlfactor = 0.0;
	 end; elseif (vfeetype = 4) /*reduced*/	then begin
				if (((vsmflag = 3) or (vsmflag = 4))) then begin
						set vlfactor = 1.0;
				end; end if;
	 end; elseif (vfeetype = 5) /*report only*/ then begin
				set vlfactor =  1/3;
	 end; elseif ((vfeetype = 6) or (vfeetype = 1))	then begin
				set vlfactor = 1.0; /*hed med perc gedoien in ou dae*/
	 end; elseif ((vfeetype = 2)  or (vfeetype = 7) )	then begin
                set vlfactor =  1.0;
     end;
	end if;
/*set vDESCRIPTION = concat('vfeetype : ',vfeetype);                                   */
     if ((vfeetype <> 6) ) then 	begin
	   if ((vfeetype = 1) ) then 	begin
				/* vfeetype = normal or custom_normal */
				set vCOST = (vPRICE  * vlfactor)  * vquantity;
		end; else 	begin
				if (vlfactor <= 1) then 	begin
						if (vlfactor = 0) then begin
								set vCOST = 0;
						end; else 
  						  /*set vCOST = (vPRICE - (vPRICE  * vlfactor))  * vquantity;*/
                          set vCOST = (vPRICE  * vlfactor)  * vquantity;
						end if;
				end; else begin
					set vCOST = (vPRICE  * vlfactor)  * vquantity;
				end; end if;
		end; end if;
     end; end if;   

     set vvatamount = 0.0;
    if (vCOST <> 0.0) then begin                        
		if (vaddvat = 1) then 
			begin
					set vCOST = vCOST * vvatmultiplier;
					set vvatamount = ( vCOST * vvatmultiplier) - vCOST ;
			end; else begin
              set vvatamount = vCOST - ( vCOST / vvatmultiplier); 
            end;
		end if;
    end; end if;
    
    if ((vfeetype = 6) ) then 	begin 
      set vFEED = 1; /*this is just called if the value was specifically set, thus make sure it is FEED then*/
    end; end if;   
    
	update fees f
		set f.fCost = vCOST,
			f.fVatAmount = vvatamount,
            f.iQuantity = vquantity,
            f.sDescription = vDESCRIPTION,
            f.bFEED = vFEED
	where f.ipkFeeID = vfeeid;
    
    	if (vfeetype = 7) then 	begin
			/*set vPRICEdividedby2 = vPRICE / 2;*/
            select sum(fCost) into vPRICE from fees where ifkAccountID = vaccountid and sMandatory <> 'e' and bFEED = 1 and (sSMFlag = 2 or sSMFlag = 1);
			set vPRICEoneandahalf = vPRICE /2 ;
			update fees set fCost = vPRICEoneandahalf where  ifkAccountID = vaccountid and sMandatory = 'e';
	end;	end if;
    
     call UpdateVisitTotals (vaccountid);
	 call Log_FeeChange(vfeeid);
end$$

delimiter ;

