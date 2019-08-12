use `promed`;
drop procedure if exists `Debtor_MoneyMovementAudit_Add`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_MoneyMovementAudit_Add`(in vpracid bigint,
											in vrefid bigint,
                                            in vfAmount decimal(18,2),
                                            in vfVatAmount decimal(18,2),
                                            in vsSource varchar(10),
											in vcaptuedby bigint)
begin

  /* 
    ment for the on insert triggers on tables that has balancee effects
    vfAmount will be total amount including the vat portion if any.
  */
  
  declare vpracbal  decimal(18,2);
  
  select fBalance into vpracbal from debtor_practice_info where ifkPracticeInfoID = vpracid;
  
  /* only if practice is setup to have a  opening balance start logging*/
  if (vpracbal is not null) then begin
     set vfAmount = -1 * vfAmount;
     set vpracbal = (vpracbal + vfAmount );  /*reason it subtracts is the outstanding amount takes from the balance, till the payment comes in that adds to balance (payment is - * - )
	 */
    insert into debtor_money_movement (ipkMoneyMovementID,sSource,iRefID,fAmount,fVatAmount,fPracticeBalance,ifkPracticeInfoID,ifkCapturedUser)  values (0, vsSource,vrefid, vfAmount, vfVatAmount,(vpracbal),vpracid,vcaptuedby);
	update debtor_practice_info set fBalance = vpracbal   where ifkPracticeInfoID = vpracid;
 
  end; end if;
  
end$$

delimiter ;

