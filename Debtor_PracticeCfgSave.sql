use `promed`;
drop procedure if exists `Debtor_PracticeCfgSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_PracticeCfgSave`(in vpracid bigint,
											in  vyearendmonth integer,
                                            in vmanualdbWriteOff decimal(18,2),
                                            in vautodbWriteOff  decimal(18,2),
                                            in vautohandoverage integer,
                                            in vautohandovervalue  decimal(18,2),
                                            in vbalance decimal(18,2),
											in vcapturedby bigint,
											in vfinalnotice integer,
											in vstatementprinterNAME varchar(150))
begin

    declare vexits integer;
  	select count(ifkPracticeInfoID) into vexits from debtor_practice_info where ifkPracticeInfoID =  vpracid;
	if (vexits <= 0) then begin
	  insert into debtor_practice_info (ifkPracticeInfoID,fBalance,iYearEndMonth,dLastDayEnd,iActiveMonth,fManual_SB_Writeoff,fAuto_SB_Writeoff,iAuto_HandOver_Age,fAuto_HandOver_Value,sStatementPrinterName,iFinalNotice_AgeID) 
			values 
			(vpracid,vbalance,vyearendmonth,current_date(),current_date(),vmanualdbWriteOff,vautodbWriteOff,vautohandoverage,vautohandovervalue,vstatementprinterNAME,vfinalnotice);
			 call Debtor_MoneyMovementAudit_Add(vpracid,vpracid,0,0,'pracinfo',vcapturedby);             
	end; else begin
		update debtor_practice_info
		set
		fBalance = vbalance,
		iYearEndMonth = vyearendmonth,
		fManual_SB_Writeoff = vmanualdbWriteOff,
		fAuto_SB_Writeoff = vautodbWriteOff,
		iAuto_HandOver_Age = vautohandoverage,
		fAuto_HandOver_Value = vautohandovervalue,
		sStatementPrinterName = vstatementprinterNAME,
		iFinalNotice_AgeID = vfinalnotice
		where ifkPracticeInfoID = vpracid;
		call Debtor_MoneyMovementAudit_Add(vpracid,vpracid,0,0,'pracinfo',vcapturedby);             
    
    end; end if;
  
end$$

delimiter ;

