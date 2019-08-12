use `promed`;
drop procedure if exists `CommsSMSReceive`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `CommsSMSReceive`(in v_sSmsId varchar(20),in v_sRefNumber varchar(15),in v_sCell varchar(20) ,in v_sMSG varchar(255))
begin
  /*
    developer : johannes
    date : 28 march 2018
    purpose : to receive a sms response and try and match it to a account first and if no account found for the ref NUMBER then try and
				match to a booking. if none is found it is still stored but the matched value in table is set to 0. else the found id is stored
                in the appropiate kolom
  */
  
  declare vid bigint;
  declare viaccount bigint;
  declare vibooking bigint;
  declare vimatched int;
  
  set vid = null;
  set vimatched = 0;
  set viaccount = 0;
  set vibooking = 0;
  
  select ipkAccountID into vid from accounts where sAccountCode = v_sRefNumber;
  
  if ((vid > 0) and (vid is not null)) then begin
    /*found account*/
    set vimatched = 1;
    set viaccount = vid;
  end; else  begin
    set vid = null;
    select ipkBookingID into vid from bookings where sBookingCode = v_sRefNumber;
    if ((vid > 0) and (vid is not null)) then begin
       set vibooking = vid;
       set vimatched = 1;
    end; end if;
  end; end if;
  insert into comms_sms_receive (ipkSMSReceiveID, sRef_number, sSmsId, sMessage, ifkAccountID, ifkBookingID, bMatched,dDateEntered,sCellnumber)
			values
	(0,v_sRefNumber,v_sSmsId,v_sMSG,viaccount,vibooking,vimatched,current_timestamp,v_sCell);

end$$

delimiter ;

