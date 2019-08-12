USE `promed`;
DROP procedure IF EXISTS `CreateStudyUIDProc`;

DELIMITER $$
USE `promed`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateStudyUIDProc`(IN vVersionNumber varchar(50), 
										OUT vSuid varchar(64))
BEGIN
	declare vDateString varchar(50);
	declare vRandomString1 varchar(40);
	declare vRandomnumber1 bigint;
	declare vRandomString2 varchar(40);
	declare vRandomnumber2 bigint;
	declare vPrefixNumber varchar(30);
    SET autocommit = 0;
	
    SET vDateString = CONCAT(REPLACE(CAST(CURRENT_TIMESTAMP AS DATE), '-', ''), REPLACE(REPLACE(CAST(CURRENT_TIMESTAMP AS TIME), ':', ''), '.', ''));
    SET vRandomString1 = RAND();
    SET vRandomString1 = RIGHT(LEFT(vRandomString1, 6) ,4);
	set vRandomnumber1 =  vRandomString1;
    SET vRandomString2 = RAND();
    SET vRandomString2 = RIGHT(LEFT(vRandomString2, 6) ,4);
	set vRandomnumber2 =  vRandomString2;
    SET vPrefixNumber = '1.2.528.1.1001.3.500.16';

    SET vSuid = CONCAT(vPrefixNumber, '.', vRandomnumber1, '.', vRandomnumber2, '.', vDateString);
END$$

DELIMITER ;

