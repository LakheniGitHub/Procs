use `promed`;
drop procedure if exists `LookupQuote`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `LookupQuote`(in vquoteid bigint)
begin
	select q.ipkQuoteID, q.dDateEntered, q.ifkTitleID, q.sFirstName, q.sInitials, q.sSurname, 
						q.sIDNumber, q.dDateOfBirth, q.sCell, q.sHome, q.sWork, q.sFax, q.ifkMedicalAidID, 
						q.ifkMedicalAidPlanID, q.sMemberNumber, q.ifkPrimaryDoctorID, q.ifkaccountID, q.bLinked, q.ifkBookingID, 
						q.fQuoteTotal, q.fFeeFactor, q.fFeeSpecialAmount, q.ifkFeeingTypeID,ma.sCode as medicalaidcode,ma.sName as medicalaidname,
						map.sGlobalMedicalAidCode as globalmedicalaidcode,b.sBookingCode,a.sAccountCode,
					    map.sOptionName as medicalaidplanname,concat('q',q.ipkQuoteID) as squotenumber
						from quote q	left join medical_aid ma on ma.ipkMedicalAidID = q.ifkMedicalAidID
					left join medical_aid_plan map on map.ipkMedicalAidPlanID = q.ifkMedicalAidPlanID 
					left join bookings b on b.ipkBookingID = q.ifkBookingID 
					left join accounts a on a.ipkAccountID = q.ifkaccountID
					where q.ipkQuoteID = vquoteid;
end$$

delimiter ;

