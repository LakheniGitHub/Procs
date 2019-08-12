use `promed`;
drop procedure if exists `Debtor_GetFeeStruct`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_GetFeeStruct`(in vramsCode varchar(10),in vmedaidid bigint,in vmedaidplanid bigint,in vtargetdate date,in vfeetype integer,
													in vspecialPRICE decimal(18,2),
													in vfactor decimal(18,2))
begin
      declare v_iLINENUMBER integer;
   declare v_sSMFlag integer;
   declare v_sSMCode  varchar(10);
   declare v_sDescription varchar(100);
   declare v_iMINVal integer;
   declare v_iMAXVal integer;
   declare v_sMandatory char(1);
   declare v_sLookupCode varchar(100);
   declare v_sRAMSCode varchar(10);
   declare v_sMTarrif varchar(10);
   declare v_LINEtype char(1);
   declare v_iPERCENTAGE integer;
   declare v_iRateCode integer;
   declare v_fServiceValue decimal(18,2);
   declare v_sTarrifCode varchar(10);
   declare v_iisdaar integer;
   
	
	
	
 declare vLINEexist int;
    declare vaccid bigint;
    
  
  
	declare vMAXval integer;
	declare vMINval integer;
	declare vQTY integer;
	declare vtmpQTY integer;
	declare vdescrip varchar(100);
	declare vsmCODE varchar(10);
    declare vMEDAIDCODE varchar(10);
	declare vMTARRIF varchar(10);
	declare vstrucCODE varchar(10);
	declare vexaMINationdate timestamp;

    declare vExamDate timestamp;
	declare vDEPARTMENT integer;
	declare vlookuPCODE varchar(10);
	
	declare vsmflag integer;
	declare vLINEnum integer;
	declare vvisit integer;
	declare vexamref integer;
	declare vMAXLINE integer;
	declare vnewdone integer;
	declare vLINEcounter integer;
	declare vLINEitterator integer;
	declare vPRICE float;
	declare vtarriFCODE varchar(10);
	declare vrate integer;
	declare vafterhours varchar(1);
	declare vpercind varchar(1);
	declare vFILM float;
	declare vvatmultiplier decimal(18,2);
	declare vaddvat integer;
	declare vmedaidperc float;
	declare vPRICEoneandahalf float;
	declare vchecktrigger integer;
    declare vfeeingstatus integer;
    declare vaccFEEDstatus varchar(1);	
    declare vperc float;
	declare vbFEED smallint;
    declare vexported integer;	
    declare vlfactor float;
	declare accountexamscurscompleted integer default 0;
    declare vreducematerial integer;
    declare vchargematerial integer;
    declare vemergencyCODE varchar(10) default '01020'; /*was 0001 */
    declare vemergencydesc varchar(100) default 'emergency call out fee, subsequent case'; /*'*** emergency ***';*/
    declare vcreatehosp integer default 1;
    declare vishosppatient integer;
    declare vFEEDstatus integer;
	declare vfirsttime integer;
	declare vtmprate integer;
	declare vtmpMEDAIDCODE varchar(10);
	declare vtmpmedaidid bigint;
	declare vtmpmedaidplanid bigint;
    declare vtmpfeeingtype bigint;
	
	/*fee LINE creation*/
	declare voutmcp varchar(2);
	declare voutCOSTPRICE decimal(18,2);
    declare voutvatamount decimal(18,2);
	declare voutLINE  integer;
	declare voutMIN integer;
	declare voutMAX integer;
	declare voutFEED integer;
	declare voutCommentLINE tinyint;
	declare voutquantity integer;	
	declare vredp varchar(10);
	
   
   declare done int default false;
   
   
   declare cur_struct cursor for select rsd.iLINENUMBER, 
										rsd.sSMFlag, 
										rsd.sSMCode, 
										rsd.sDescription, 
										case when ifnull(rsd.iMINVal,0) < 1 then 1 else rsd.iMINVal end as iMINVal,
										case when ifnull(rsd.iMAXVal,0) < case when ifnull(rsd.iMINVal,0) < 1 then 1 else rsd.iMINVal end then case when ifnull(rsd.iMINVal,0) < 1 then 1 else rsd.iMINVal end else rsd.iMAXVal end as iMAXVal, 
										ifnull(rsd.sMandatory,0), 
										rsd.sLookupCode, 
										rsd.sRAMSCode, 
										rsd.sMTarrif,
										case when rsd.sSMFlag in (1,2) then 'p' else 'm' end as LINEtype,
										ma.iPERCENTAGE,ma.iRateCode  ,ma.sCode
								from rams_structure_detail rsd,medical_aid ma
								where  rsd.sRAMSCode = vramsCode
										and  ma.ipkMedicalAidID = vmedaidid;
                                        
	declare continue handler for not found set done = true;    
                                        
   drop temporary table if exists tmpfeestruct;	
   
       create temporary table tmpfeestruct    (
		   iLINENUMBER integer,
		   sSMFlag integer,
		   sSMCode  varchar(10),
		   sDescription varchar(100),
		   iMINVal integer,
		   iMAXVal integer,
		   sMandatory char(1),
		   sLookupCode varchar(10),
		   sRAMSCode varchar(10),
		   sMTarrif varchar(10),
		   LINEtype char(1),
		   iPERCENTAGE integer,
		   iRateCode integer,
		   fServiceValue decimal(18,2),
		   sTarrifCode varchar(10),
		   iQTY integer,
		   bFEED integer,
		   icustomLINE integer,
		   fVatAmount decimal(18,2)
    ) engine=memory;                                          
                                        
    select vf.fVATMultiplication, vf.bAddVAT into   vvatmultiplier, vaddvat    from   vat_factor vf;
    /****************************************************************************/
    /*                                                                          */
    /* please remember:                                                         */
    /*     PRICE is original value and COST is calculated from this             */
    /*     COST is for display purpouse                                         */
    /*                                                                          */
	/*		1 = normal 															*/
	/*		2 = after hours														*/	
	/*		3 = special															*/	
	/*		4 = reduced															*/
	/*		5 = report only														*/
	/*		6 = custom normal													*/
	/*		7 = 50% after hours													*/
	/*		8 = hospital   													    */
    /* 																			*/	
    /****************************************************************************/
	
    open cur_struct;
    set done = false ;    
	/* maybe add dunno ?
	call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,0 ,0 ,0 ,1 ,'m',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,'hospital patient',voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'ihosp',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,'00091',voutquantity,voutFEED,voutCommentLINE,0);	
														
		call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, 'hospital patient', 1, 0, 0, 0, 1, 'm', 0, '00091', 0, 0, vexaMINationdate, vuserNAME, '', 'ihosp', vvatmultiplier, vaddvat, 1, vfeetype, 1);

call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,0 ,0 ,0 ,1 ,'m',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,'out patient',voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'ohosp',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,'00092',voutquantity,voutFEED,voutCommentLINE,0);	
														
		call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, 'out patient', 1, 0, 0, 0, 1, 'm', 0, '00092', 0, 0, vexaMINationdate, vuserNAME, '', 'ohosp', vvatmultiplier, vaddvat, 1, vfeetype, 1);

	*/
    
    read_loop_exams: loop
		fetch cur_struct into v_iLINENUMBER,v_sSMFlag ,v_sSMCode ,v_sDescription,v_iMINVal,v_iMAXVal,v_sMandatory,v_sLookupCode,v_sRAMSCode,v_sMTarrif,
								v_LINEtype,v_iPERCENTAGE,v_iRateCode,vMEDAIDCODE;
			if done then
			  leave read_loop_exams;
			end if;
			/*iniz values per LINE*/
			
			set vlfactor = ifnull(vfactor, 1.0);
			set vtmprate  = vrate;
			set vtmpMEDAIDCODE = vMEDAIDCODE;
			set vtmpmedaidid  = vmedaidid;
			set vtmpmedaidplanid  = vmedaidplanid;		
			set vafterhours = 'n';
			set vpercind = null;
			set vFILM = 0.0;
			call GenGetFeePRICE(v_sSMFlag, v_iRateCode, v_sSMCode, v_sLookupCode, vMEDAIDCODE,vmedaidid,vmedaidplanid,v_iMINVal,date(vtargetdate),v_fServiceValue,v_sTarrifCode,vafterhours,vFILM,vpercind);

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
			set vbFEED = 0;
			if ((v_sMandatory = 'm') ) then begin
			  set vbFEED = 1;	
			end; end if;
			set vQTY = vMINval;
			if ((vfeetype = 5) and ((v_sSMFlag = 3) or (v_sSMFlag = 4))) then begin
			   /*this is a report only fee. materials cannot be charged for a re-report*/
			   set vbFEED = 0;
			end; end if;
			if (v_sSMFlag = 3) then begin
			        call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,vQTY ,v_fServiceValue ,v_iMINVal ,v_iMAXVal ,vbFEED ,v_sMandatory,v_sSMFlag ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,null ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
					insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
								LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
								v_iLINENUMBER,v_sSMFlag ,v_sSMCode ,v_sDescription,voutMIN,voutMAX,v_sMandatory,v_sLookupCode,v_sRAMSCode,v_sMTarrif,
								v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,v_sTarrifCode,voutquantity,voutFEED,voutCommentLINE,voutvatamount);
								
			end; elseif ((v_sSMFlag = 4) ) then begin /*and (vchargematerial = 1)*/
						/*set vtarriFCODE = vMTARRIF;*/
						   call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,vQTY ,v_fServiceValue ,v_iMINVal ,v_iMAXVal ,vbFEED ,v_sMandatory,v_sSMFlag ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,null ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
								LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
								v_iLINENUMBER,v_sSMFlag ,v_sSMCode ,v_sDescription,voutMIN,voutMAX,v_sMandatory,v_sLookupCode,v_sRAMSCode,v_sMTarrif,
								v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,v_sTarrifCode,voutquantity,voutFEED,voutCommentLINE,voutvatamount);
								
			end; elseif ((v_sSMFlag = 1) or (v_sSMFlag = 2)) then begin
			            call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,vQTY ,v_fServiceValue ,v_iMINVal ,v_iMAXVal ,vbFEED ,v_sMandatory,v_sSMFlag ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,null ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,v_sSMCode ,v_sDescription,voutMIN,voutMAX,v_sMandatory,v_sLookupCode,v_sRAMSCode,v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,v_sTarrifCode,voutquantity,voutFEED,voutCommentLINE,voutvatamount);
			end; end if;	
            set vlfactor = 1.0;  /*reset factor*/			
            /*end iniz*/			
			
/*            if (v_LINEtype = 'p') then begin
              select pr.fServiceValue / 100 ,pr.sTarrifCode into v_fServiceValue ,v_sTarrifCode 
				from rams_procedure_rates pr 
				where pr.sRAMSCode = v_sSMCode 
					and pr.iRateCode = v_iRateCode  and (dEffectiveFrom <= concat(year(vtargetdate),'-','01','-','01') and dEffectiveTo = concat(year(vtargetdate),'-','12','-','31'));
            end; else begin
              
               call GenGetMaterialPRICE(v_sSMCode,vmedaidid,vmedaidplanid,v_iMINVal,vtargetdate,v_fServiceValue,v_sTarrifCode);
            end; end if;
            
            insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
								LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode) values (
            v_iLINENUMBER,v_sSMFlag ,v_sSMCode ,v_sDescription,v_iMINVal,v_iMAXVal,v_sMandatory,v_sLookupCode,v_sRAMSCode,v_sMTarrif,
								v_LINEtype,v_iPERCENTAGE,v_iRateCode,v_fServiceValue,v_sTarrifCode);
   */								
        set done = false ; 
	end loop read_loop_exams;       
	 /*reduced and special checks*/
	if (vfeetype = 7) then 	begin
	   set v_iLINENUMBER = v_iLINENUMBER + 1;
	   
				call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,0 ,0 ,0 ,1 ,'e',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,'*** +50% after hours ***',voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'emerg',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,vemergencyCODE,voutquantity,voutFEED,voutCommentLINE,voutvatamount);		   
                /*call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, '*** +50% after hours ***', 1, 0 , 0, 0, 0, 'e', 0, vemergencyCODE, 0, 0, vExamDate, vuserNAME, '', 'emerg', vvatmultiplier, vaddvat, vlfactor, vfeetype, 1);         */
														
	end;	end if;
	if (vfeetype = 2) then		begin
	call RunTriggerCheckTrns('mde', vchecktrigger); /*must do emergency also known as afterhours !*/
		if (vchecktrigger = 1)				then begin
		         set v_iLINENUMBER = v_iLINENUMBER + 1;
				call GenGetFeePRICE(2, v_iRateCode, vemergencyCODE, '', vMEDAIDCODE,vmedaidid,vmedaidplanid,1,date(vtargetdate),v_fServiceValue,v_sTarrifCode,vafterhours,vFILM,vpercind);
				call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,v_fServiceValue ,0 ,0 ,0 ,'e',2 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,vemergencydesc,voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'emerg',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,vemergencyCODE,voutquantity,voutFEED,voutCommentLINE,voutvatamount);
				/*call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, vemergencydesc, 1, vPRICE, 0, 0, 0, 'e', 0, vemergencyCODE, 0, 2, vExamDate, vuserNAME, '', 'emerg', vvatmultiplier,vaddvat, vlfactor, vfeetype, 1);*/
		end;			end if;
	end;	end if;
	if (vfeetype = 3) then 		begin
	     set v_iLINENUMBER = v_iLINENUMBER + 1;
	      set vlfactor = 1.0;
				call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,vspecialPRICE ,0 ,0 ,1 ,'s',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,'*** special ***',voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'special',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,0,voutquantity,voutFEED,voutCommentLINE,voutvatamount);
		  
		/*call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, '*** special ***', 1, vspecialPRICE, 0, 0, 1, 's', 0, 0, 0, 0, vExamDate, vuserNAME, '', 'special', vvatmultiplier,vaddvat, vlfactor, vfeetype, 1);*/
            
	end;	end if;    
	if (vfeetype = 4) then 		begin
	   set v_iLINENUMBER = v_iLINENUMBER + 1;
	   set vredp = (1 -  vfactor) * 100;
	   set vredp = ifnull(vredp,'');
	   if (vredp <> '') then begin
	     set vredp = concat(vredp,'%');
	   end; end if;
				call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,0 ,0 ,0 ,1 ,'r',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,concat('*** reduced ',vredp,'***'),voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'reduced',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,0,voutquantity,voutFEED,voutCommentLINE,voutvatamount);	   
	   /*call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, '*** reduced ***', 1, 0, 0, 0, 1, 'r', 0, 0, 0, 0, vExamDate, vuserNAME, '', 'reduced', vvatmultiplier, vaddvat, vlfactor,vfeetype, 1);*/
	end; end if;
	if (vfeetype = 5) then 		begin
	    set v_iLINENUMBER = v_iLINENUMBER + 1;
				call GenCreateFeeLINEEntryData(null ,v_iLINENUMBER ,1 ,0 ,0 ,0 ,1 ,'r',0 ,vvatmultiplier ,vaddvat ,vlfactor ,vfeetype ,1 ,									
									 voutLINE  ,voutMIN ,voutMAX , voutFEED , voutCommentLINE , voutvatamount, voutmcp , voutCOSTPRICE,voutquantity );
									 
						insert into tmpfeestruct (iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
														LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount) values (
														v_iLINENUMBER,v_sSMFlag ,'' ,'*** report ***',voutMIN,voutMAX,v_sMandatory,v_sLookupCode,'reporto',v_sMTarrif,
														v_LINEtype,v_iPERCENTAGE,v_iRateCode,voutCOSTPRICE,0,voutquantity,voutFEED,voutCommentLINE,voutvatamount);	   
		
/*	   call GenCreateFeeLINE(vaccid, vvisit, vexamref, vLINEcounter, vLINEitterator, '*** report ***', 1, 0, 0, 0, 1,'r', 0, 0, 0, 0, vExamDate, vuserNAME, '', 'reporto', vvatmultiplier, vaddvat, vlfactor,vfeetype, 1);            */
	end; end if;
    
    select iLINENUMBER,sSMFlag ,sSMCode ,sDescription,iMINVal,iMAXVal,sMandatory,sLookupCode,sRAMSCode,sMTarrif,
								LINEtype,iPERCENTAGE,iRateCode,fServiceValue,sTarrifCode,iQTY,bFEED,icustomLINE,fVatAmount from tmpfeestruct order by iLINENUMBER;
    
    drop temporary table if exists tmpfeestruct;	
end$$

delimiter ;

