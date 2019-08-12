use `promed`;
drop procedure if exists `GenGetMaterialPrice`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `GenGetMaterialPrice`(in vcode varchar(10),
                  in vmedaidid bigint,in vmedaidplanid bigint,in vqty integer,in vtargetdate date,out iSellingPrice decimal(18,4),out sTarrifCode varchar(10))
begin
    declare vexists integer;
	declare v_sch integer;
	declare vmarkupmethod integer;
	declare v_codeeath varchar(10);
	declare v_simflg char(1);
	declare tmp_price decimal(18,2);
	declare tmp_markup_price decimal(18,2);
	declare vtmpqty integer; 
	declare v_capamount decimal(18,2);
	declare v_markup decimal(18,2);
	declare v_fixfee decimal(18,2);
	declare v_baddvat smallint;
	declare vvatmulit decimal(18,2)	;
	declare v_isellingprice decimal(18,4);
	/* on success return 1 , else 0 */
    	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[ggmp]:',MSG),1,128);   	
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
   
    call RunTriggerCheckTrns('UGM', vexists);
	/*
	  if ugm is set, use global med aid CODE (plan). else use old method that just check med aid CODE
	*/
	if ((vexists = 1) and (vmedaidplanid is not null) and (vmedaidplanid > 0)) then begin
          
        select bAddVAT,fVATMultiplication into v_baddvat,vvatmulit  from vat_factor;            
		if exists (select COMATC
					  from   rams_material_base
					  where  COMATC = vcode
					  and  ifkMedicalAidPlan = vmedaidplanid and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'))) then
					  
				select W_CSPRCE,SCHNUM,CODEETH,SIMFLG
                  into   v_isellingprice,v_sch,v_codeeath,v_simflg
				  from   rams_material_base
				  where  COMATC = vcode
				  and  ifkMedicalAidPlan = vmedaidplanid and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
				  
					/*
						on submat you will see the field SCHNUM and SIMFLG 
						n = fixed MARKUP [(QTY * base) + fixed fee], 
						y = PERCENTAGE [(QTY * base) + PERCENTAGE(markpup)]
						*/
				 set tmp_price = v_isellingprice * vqty;
				 
			   select a.FIXFEE, a.MARKUP, a.CAPAMOUNT
						from rams_material_calc a
						where v_sch >= a.SCHFROM and v_sch <= a.SCHTO  
						and tmp_price >= a.MINCOST 
						and tmp_price <= a.MAXCOST and a.CODEEC = v_codeeath and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'))
						into v_fixfee,v_markup,v_capamount;
                 set vmarkupmethod = 0;  
				 
				 if ((v_markup is not null) and (v_markup > 0) and (v_simflg = 'y')) then begin
				    set vmarkupmethod = 1;  
				   /*perc*/
				   set v_markup = v_markup / 100;
				   set v_markup = v_markup + 1;
                   
				   set tmp_price = tmp_price * v_markup;
				 end; end if;
				 
				if ((v_fixfee is not null) and (v_fixfee > 0) and  (vmarkupmethod = 0) and (v_simflg = 'n')) then begin
				   /*fixed*/
				   set tmp_price =  tmp_price + v_fixfee;
				end; end if;
				
                if (tmp_price > v_capamount) then begin
				   set tmp_price = v_capamount;
				end; end if;
				/*if (v_baddvat = 1) then begin*/
				  set tmp_price = tmp_price * vvatmulit;
				/*end; end if; */
				
				select sTarrifCode
                  into   sTarrifCode
				from   rams_material_lookup
				where  sRAMSCode = vcode;
				
				set iSellingPrice = tmp_price;        
		else
			select (rml.iSellingPrice / 100) as tmp_isellingprice, rml.sTarrifCode as tmp_starrifcode
			into iSellingPrice,sTarrifCode
			from   rams_material_lookup rml where rml.sRAMSCode = vcode and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
			set iSellingPrice = iSellingPrice * vqty;
		end if;
	end; else begin
		if exists (select rum.ipkRAMSUMaterials 
					from rams_u_materials rum
					where rum.sRAMSCode = vcode
						and rum.ifkMedicalAidID = vmedaidid and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'))) then
			select (rum.iPrice / 100) as tmp_isellingprice, rml.sTarrifCode as tmp_starrifcode
			into iSellingPrice,sTarrifCode
			from   rams_u_materials rum,rams_material_lookup rml
			where  rum.sRAMSCode = vcode
				and rml.sRAMSCode = rum.sRAMSCode
				and    rum.ifkMedicalAidID = vmedaidid and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
			set iSellingPrice = iSellingPrice * vqty;	
		else
			select (rml.iSellingPrice / 100) as tmp_isellingprice, rml.sTarrifCode as tmp_starrifcode
			into iSellingPrice,sTarrifCode
			from   rams_material_lookup rml where rml.sRAMSCode = vcode and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
			set iSellingPrice = iSellingPrice * vqty;
		end if;
    end; end if;	

	/*set iSellingPrice = iSellingPrice/100;*/
	if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  
end$$

delimiter ;

