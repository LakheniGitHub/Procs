USE `promed`;
DROP procedure IF EXISTS `GetFees`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFees`(IN vAccountCode VARCHAR(8))
BEGIN
    SELECT A.sAccountCode,
            F.iFeeLine,
			F.iFeeLineID,
            F.iSequence,
            F.iReference,
            F.iStructureLine,
            F.sSMFlag,
            F.sSMCode,
            F.sTarrifCode,
            F.sStrucCode,
            F.sDescription,
            F.iQuantity,
            F.fUnitPrice,
            F.fCost,
            F.fVATAmount,
            F.fPaidAmount,
            F.bCommentLine,
            F.bFeed,
            F.bPaidFlag,
            F.dLineDate,
            /*F.ifkDepartmentID,*/
            F.ifkVisitID,
            F.iMaximum,
            F.iMinimum,
            F.sFunderReferenceNumber,
            F.sMandatory,
            F.sMCPIND,
            F.sPayDenyReason,
            F.sPCHostName,
            F.sPCLoginName,
            F.sPCWinDescription,
            F.sPromedInitials,
            F.sPromedLoginName,
            F.sType
	FROM   fees F
	INNER JOIN accounts A
		ON A.ipkAccountID = F.ifkAccountID
	WHERE  A.sAccountCode = vAccountCode
		AND F.bFeed = 1
	ORDER  BY F.iFeeLine;
END$$

DELIMITER ;

