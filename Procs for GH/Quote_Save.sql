use `promed`;
drop procedure if exists `Quote_Save`;

delimiter $$
use `promed`$$
create procedure `Quote_Save` (in ventrid bigint,
							  in vtitleid integer,
							  in vfirstname varchar(80),
							  in vinitials varchar(10),
							  in vsurname varchar(80) ,
							  in vidnumber varchar(20) ,
							  in vdateofbirth date ,
							  in vcell varchar(20) ,
							  in vhome varchar(20) ,
							  in vwork varchar(20) ,
							  in vfax varchar(20) ,
							  in vmedicalaidid bigint(20) ,
							  in vmedicalaidplanid int(11) ,
							  in vmembernumber varchar(30) ,
							  in vprimarydoctorid int(11) ,
							  in vaccountid bigint(20) ,
							  in vlinked smallint(6) ,
							  in vbookingid int(11) ,
							  in vquotetotal decimal(18,2) ,
							  in vfeefactor decimal(18,2) ,
							  in vfeespecialamount decimal(18,2) ,
							  in vfeeingtypeid integer,
							  in vcaptureid bigint,
							  in vsiteid bigint)
begin
   declare vexist integer;
   declare quoteid bigint;
declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[qs]:',MSG),1,128);   	
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
   
   select count(*) into vexist from quote where ipkQuoteID = ventrid;
   
   if ((vexist is null) or (vexist <= 0)) then begin
		insert into quote (ipkQuoteID,dDateEntered,ifkTitleID,sFirstName,sInitials,sSurname,sIDNumber,dDateOfBirth,sCell,sHome,sWork,
					sFax,ifkMedicalAidID,ifkMedicalAidPlanID,sMemberNumber,ifkPrimaryDoctorID,ifkaccountID,bLinked,ifkBookingID,fQuoteTotal,
					fFeeFactor,fFeeSpecialAmount,ifkFeeingTypeID,ifkCaptureID,ifkSiteID) 
					values
			(0,current_timestamp,vtitleid,vfirstname,vinitials,vsurname,vidnumber,
			vdateofbirth,vcell,vhome,vwork,vfax,vmedicalaidid,vmedicalaidplanid,vmembernumber,vprimarydoctorid,
			vaccountid,vlinked,vbookingid,vquotetotal,vfeefactor,vfeespecialamount,vfeeingtypeid,vcaptureid,vsiteid);
           set quoteid = last_insert_id();
   end; else begin
		update quote
		set
		ifkTitleID = vtitleid,
		sFirstName = vfirstname,
		sInitials = vinitials,
		sSurname = vsurname,
		sIDNumber = vidnumber,
		dDateOfBirth = vdateofbirth,
		sCell = vcell,
		sHome = vhome,
		sWork = vwork,
		sFax = vfax,
		ifkMedicalAidID = vmedicalaidid,
		ifkMedicalAidPlanID = vmedicalaidplanid,
		sMemberNumber = vmembernumber,
		ifkPrimaryDoctorID = vprimarydoctorid,
		ifkaccountID = vaccountid,
		bLinked = vlinked,
		ifkBookingID = vbookingid,
		fQuoteTotal = vquotetotal,
		fFeeFactor = vfeefactor,
		fFeeSpecialAmount = vfeespecialamount,
		ifkFeeingTypeID = vfeeingtypeid,
		ifkCaptureID = vcaptureid,
		ifkSiteID = vsiteid
		where ipkQuoteID = ventrid;
   
      set quoteid = ventrid;
   end; end if;
   select quoteid ;
if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  
end$$

delimiter ;

