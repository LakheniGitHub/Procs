use `promed`;
drop procedure if exists `DebotBulkHeaderSave`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `DebotBulkHeaderSave`(in vheaderid bigint,
										in vpaymentdate timestamp,
                                        in vdescription varchar(150),
                                        in vbatch varchar(10),
                                        in vreceiptnumber varchar(15),
                                        in vpayer varchar(50),
                                        in vcaptureid bigint
                                        )
begin
   /*
     to save / update header rekord and return header id if new one added else return current header id
   */
   
   
   if ((vheaderid is null) or (vheaderid <= 0) ) then begin
					insert into debtor_bulk_payments_header (ipkBulkPaymentID,dDateEntered,dPaymentDate,sDescription,sBatchNumber,sReceiptNumber,sPayer,ifkOperatorID)
							values
					(0,current_timestamp,vpaymentdate,vdescription,vbatch,vreceiptnumber,vpayer,vcaptureid);
             select last_insert_id() as iheaderid;       
   end; else begin
			update debtor_bulk_payments_header			set
				dPaymentDate = vpaymentdate,
				sDescription = vdescription,
				sBatchNumber = vbatch,
				sReceiptNumber = vreceiptnumber,
				sPayer = vpayer,
				ifkOperatorID = vcaptureid
			where ipkBulkPaymentID = vheaderid;
       select vheaderid as iheaderid;       
   end; end if;

end$$

delimiter ;

