use `promed`;
drop procedure if exists `Debtor_OperatorCfgSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Debtor_OperatorCfgSave`(in vopid bigint,
										   in vbatchprefix varchar(2),
                                           in vbatchNUMBER integer,
                                           in vreceiptprefix varchar(2),
                                           in vreceipteNUMBER integer,
										   in vautoassign smallint)
begin
declare vexist integer;

   select count(*) into vexist from debtor_operators_cfg where ifkOperatorID = vopid;
   if ((vexist is null) or (vexist <= 0)) then begin
		insert into debtor_operators_cfg (iReceiptBatchNUMBER,sReceiptBatchPrefix,dSessionDate,iReceiptNUMBER,sReceiptPrefix,ifkOperatorID,bDebtorAutoAssign)
		values
		(vbatchNUMBER,vbatchprefix,current_date,vreceipteNUMBER,vreceiptprefix,vopid,vautoassign);

   end; else begin
	update debtor_operators_cfg
		set
			iReceiptBatchNUMBER = vbatchNUMBER,
			sReceiptBatchPrefix = vbatchprefix,
			iReceiptNUMBER = vreceipteNUMBER,
			sReceiptPrefix = vreceiptprefix,
			bDebtorAutoAssign = vautoassign
		where ifkOperatorID = vopid;
   end; end if;
end$$

delimiter ;

