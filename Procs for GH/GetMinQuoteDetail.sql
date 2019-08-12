use `promed`;
drop procedure if exists `GetMinQuoteDetail`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `GetMinQuoteDetail`(in vquoteid bigint)
begin 

	select 					
							ma.sCode as sMedicalAidCode,
							ma.sEmail as smedicalemail,
							map.sGlobalMedicalAidCode ,
							q.ifkMedicalAidID,
							q.ifkSiteID,
							s.sSiteFolder,
							s.sSiteName,
							s.sFinalNoticeReport,
							s.sHandOverReport,
							s.sStatementReport,
							s.sReceiptReport,
							s.sJobcardReport,
							s.sPatientInfoReport,
							s.sLabelReport,
							s.sStatementExclReport,
							s.sQuoteReport,
							q.ipkQuoteID
					from sites s, medical_aid ma ,quote 	q left join medical_aid_plan map on (map.ipkMedicalAidPlanID = q.ifkMedicalAidPlanID)
					where q.ipkQuoteID = vquoteid and ma.ipkMedicalAidID = q.ifkMedicalAidID  and s.ipkSiteID = q.ifkSiteID;
	
end$$

delimiter ;

