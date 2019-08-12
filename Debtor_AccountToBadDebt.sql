use `promed`;
drop procedure if exists `Debtor_AccountToBadDebt`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_AccountToBadDebt`(in v_accountid bigint,
			in v_bLocalListing smallint,
            in v_bHandedOver smallint,
            in v_capturedby bigint)
begin
 /*
  v_bLocalListing = blacklisted in practice.
  v_bHandedOver = handed over to somebody like itc,compsol etc (handover_to table)
  else the default is a plain bad debt (both above = 0)
  
  NOTE : that the times person is listed is checked against persons surname and id NUMBER.
  
 */
declare v_imemberid bigint;
declare v_exist smallint;
declare v_sMedicalAidCode varchar(30);
declare v_sTITLE  varchar(10);
declare v_sInitials  varchar(10);
declare v_sName  varchar(50);
declare v_ssurname  varchar(80);
declare v_dDateOfBirth date;
declare v_sIdenityNumber  varchar(15);
declare v_sAddress1  varchar(30);
declare v_sAddress2  varchar(30);
declare v_sAddress3  varchar(30);
declare v_sAddress4  varchar(30);
declare v_sPostalCode  varchar(10);
declare v_sMedicalAidName  varchar(20);
declare v_sMedicalAidNumber  varchar(20);
declare v_iBalanceOwed bigint;
declare v_fTotalOwed  decimal(18,2);
declare v_ftmptotalowed  decimal(18,2);
declare v_dExaMINationDate timestamp;
declare v_sDefaulterCode  varchar(10);
declare v_sMCWCode  varchar(10);
declare v_sAccountCode  varchar(10);
declare v_sHometel  varchar(10);
declare v_sWorktel  varchar(10);
declare v_sEmployer  varchar(30);
declare v_sDOWETO  varchar(10);
declare v_iTimesListed integer;

 declare MSG varchar(128);
 declare exit handler for sqlexception
 begin 
 /*need MIN mysql 5.6.4 */
	get diagnostics condition 1 MSG = message_text;
    set MSG = substring(concat('[datbd]:',MSG),1,128);   	
		rollback;
    set @g_transAction_started = 0;
    signal sqlstate '45000' set message_text = MSG;
 end;
 
  set autocommit = 0;
   if ((@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
     start transAction;  
     set @g_transAction_started = 1;
   end; else begin
    set @g_transAction_started = @g_transAction_started + 1;
   end; end if;
 
select ifkMemberID,fBalance,sAccountCode,dExamDate into v_imemberid,v_ftmptotalowed,v_sAccountCode,v_dExaMINationDate from accounts a where ipkAccountID = v_accountid;

select ifnull(count(ipkBadDeptID),0) into v_exist from bad_debts where sAccountCode = v_sAccountCode;


select m.sMedicalAidReference,ma.sCode,m.sTITLE,m.sInitials,m.sName,m.ssurname,m.dMemberDateOfBirth ,m.sIDNumber,ma.sName,m.sHometel,m.sWorktel,m.sEmployer
       into v_sMedicalAidNumber,v_sMedicalAidCode,v_sTITLE,v_sInitials ,v_sName,v_ssurname,v_dDateOfBirth,v_sIdenityNumber,v_sMedicalAidName,v_sHometel,v_sWorktel,v_sEmployer
		from members m, medical_aid ma where m.ipkMemberID = v_imemberid and m.ifkMedicalAidID = ma.ipkMedicalAidID;

select sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode  into v_sAddress1,v_sAddress2,v_sAddress3,v_sAddress4,v_sPostalCode 
      from member_addresses where ifkMemberID = v_imemberid and ifkMemberAddressTypeID = 1;
      
      if ((v_sAddress1 is null) or (v_sAddress1 = '')) then begin
			select sAddressLine1,sAddressLine2,sAddressLine3,sAddressLine4,sPostalCode  into v_sAddress1,v_sAddress2,v_sAddress3,v_sAddress4,v_sPostalCode 
				  from member_addresses where ifkMemberID = v_imemberid and ifkMemberAddressTypeID = 2;
      end; end if;
select ifnull(count(ipkBadDeptID),0) into  v_iTimesListed from bad_debts where ssurname = v_ssurname and sIdenityNumber = v_sIdenityNumber;      
	if (v_exist = 0) then begin
        set    v_fTotalOwed = v_ftmptotalowed;
		set v_iBalanceOwed = v_fTotalOwed * 100;

		insert into bad_debts (ipkBadDeptID, sMedicalAidCode,sTITLE,sInitials,sName,ssurname,
								dDateOfBirth,sIdenityNumber,sAddress1,sAddress2,sAddress3,sAddress4,
								sPostalCode,sMedicalAidName,sMedicalAidNumber,iBalanceOwed,fTotalOwed,dExaMINationDate,
								sDefaulterCode,sMCWCode,bLocalListing,iTimesListed,sAccountCode,sHometel,sWorktel,bHandedOver,
								sEmployer,sDOWETO,ifkCapturedBy,ifkAccountID)
					values
						(0,v_sMedicalAidCode,v_sTITLE,v_sInitials ,v_sName,v_ssurname,
						v_dDateOfBirth,v_sIdenityNumber,v_sAddress1,v_sAddress2,v_sAddress3,
						v_sAddress4,v_sPostalCode,v_sMedicalAidName,v_sMedicalAidNumber,v_iBalanceOwed,v_fTotalOwed,
							v_dExaMINationDate,v_sDefaulterCode,v_sMCWCode,v_bLocalListing,v_iTimesListed,v_sAccountCode,
						v_sHometel,v_sWorktel,v_bHandedOver,v_sEmployer,v_sDOWETO,v_capturedby,v_accountid);
	end; else begin
      set v_iBalanceOwed = v_ftmptotalowed * 100;
       update bad_debts
       set iTimesListed = v_iTimesListed,
       iBalanceOwed = v_iBalanceOwed,
       bHandedOver = v_bHandedOver,
       bLocalListing = v_bLocalListing
       where sAccountCode = v_sAccountCode;
	end; end if;     
	/*if (v_bHandedOver = 1) then begin
	  update debtor_additional set bHandOver = 1 where ifkAccountID = v_accountid;
	end; end if;
	if (v_bLocalListing = 1) then begin
	  update debtor_additional set bBlackListed = 1 where ifkAccountID = v_accountid;
	end; else begin
	  update debtor_additional set bBadDebt = 1 where ifkAccountID = v_accountid;
	end; end if;	
	*/
	
	     if ((@g_transAction_started = 1) or  (@g_transAction_started = 0) or (@g_transAction_started is null)) then begin
    commit;
     set @g_transAction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transAction_started = @g_transAction_started - 1;
  end; end if;
end$$

delimiter ;

