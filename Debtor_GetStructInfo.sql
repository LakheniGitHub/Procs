use `promed`;
drop procedure if exists `Debtor_GetStructInfo`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_GetStructInfo`(in v_imedaid bigint, 
										in v_imedaidplan bigint, 
										in v_sSMCode varchar(10),
                                        in v_sLineType char(1),
                                        in v_QTY integer,
										in vtargetdate date,
										in vfeetype integer,
										in vspecialPRICE decimal(18,2),
										in vfactor decimal(18,2),
										in v_sSMFlag integer,
										in v_lookuPCODE varchar(10),
										in v_MIN integer,
										in v_MAX integer)
begin
  /*
    developer : johannes
    dae : 15 maart 2018
    purpose : to get the PRICE and tarrif info for specific smCODE based on med aid etc
    NOTE v_sLineType = p = procedure, m = material
  */
  
  declare v_iRateCode integer;
  declare v_iisdaar integer;
  
  declare v_fPRICE decimal(18,2);
  declare v_starrif varchar(10);
  declare v_sNappi varchar(10);
  declare v_sMTarrif varchar(10);
  declare vMEDAIDCODE varchar(10);
  declare vafterhours varchar(1);
  declare vFILM float;
  declare vpercind varchar(1);
  declare vvatmultiplier decimal(18,2);
	declare vaddvat integer;
	
	declare voutmcp varchar(2);
	declare voutCOSTPRICE decimal(18,2);
    declare vvatamount decimal(18,2);
	declare voutLINE  integer;
	declare voutMIN integer;
	declare voutMAX integer;
	declare voutFEED integer;
	declare voutCommentLINE tinyint;
	declare voutquantity integer;
	declare vlfactor decimal(18,2);
	declare v_iPERCENTAGE decimal(18,2);
  
  declare v_iLINENUMBER integer;
  
  select iRateCode,sCode,iPERCENTAGE into v_iRateCode,vMEDAIDCODE,v_iPERCENTAGE from medical_aid where ipkMedicalAidID = v_imedaid;
  select vf.fVATMultiplication, vf.bAddVAT into   vvatmultiplier, vaddvat    from   vat_factor vf;
  set vlfactor = ifnull(vfactor, 1.0);
  
  call GenGetFeePRICE(v_sSMFlag, v_iRateCode, v_sSMCode, v_lookuPCODE, vMEDAIDCODE,v_imedaid,v_imedaidplan,v_QTY,date(vtargetdate),v_fPRICE,v_starrif,vafterhours,vFILM,vpercind);
  if (vfeetype = 3) /*special one fee PRICE*/	then begin
			set vlfactor = 0.0;
	/* end; elseif (vfeetype = 4) 	then begin /*reduced
			if ((vreducematerial = 0) and ((v_sSMFlag = 3) or (v_sSMFlag = 4))) then begin
					set vlfactor = 1.0;
			end; end if;*/
  end; elseif (vfeetype = 5) /*report only*/ then begin
			set vlfactor =  1/3;
  end; elseif ((vfeetype = 6) or (vfeetype = 1))	then begin /*normal and custom normal*/
				set vlfactor =  (v_iPERCENTAGE / 100);
  end; elseif ((vfeetype = 2) or (vfeetype = 7) )	then begin  /*after hours and 50% afterhours*/
		  set vlfactor =  1.0;
  end; elseif ((vfeetype = 8)  )	then begin /* hospital*/
		  set vlfactor =  0.75;
  end; end if;
  set voutCOSTPRICE = 0.0;	
  /*select v_fPRICE,v_starrif,v_sNappi,v_sMTarrif,vvatamount,vlfactor,vvatmultiplier,voutCOSTPRICE;  */
  call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,v_QTY ,v_fPRICE ,v_MIN ,v_MAX ,1 ,'',v_sSMFlag ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,null ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , vvatamount, voutmcp , voutCOSTPRICE,voutquantity );
    /*select v_fPRICE,v_starrif,v_sNappi,v_sMTarrif,vvatamount,vlfactor,vvatmultiplier,voutCOSTPRICE;  */
  set v_fPRICE =   voutCOSTPRICE;
  if (v_sLineType = 'm') then begin
      set v_sNappi =  v_sSMCode;
	  select sMTarrif into v_sMTarrif from rams_structure_detail where sSMCode = v_sSMCode limit 1;
  end; else begin
     set v_sMTarrif = '';
     set v_sNappi = '';  
  end; end if;  
  
/*  if (v_sLineType = 'm') then begin
      set v_sNappi =  v_sSMCode;
      select sMTarrif into v_sMTarrif from rams_structure_detail where sSMCode = v_sSMCode limit 1;
      
      call GenGetMaterialPRICE(v_sSMCode,v_imedaid,v_imedaidplan,v_QTY,vtargetdate,v_fPRICE,v_starrif);
      
  end; else begin
     set v_sMTarrif = '';
     set v_sNappi = '';
     select pr.fServiceValue,pr.sTarrifCode into v_fPRICE ,v_starrif 
				from rams_procedure_rates pr 
				where pr.sRAMSCode = v_sSMCode 
					and pr.iRateCode = v_iRateCode  and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
  end; end if;
*/  
  select v_fPRICE,v_starrif,v_sNappi,v_sMTarrif,vvatamount,vlfactor,vvatmultiplier,voutCOSTPRICE;
  
end$$

delimiter ;

