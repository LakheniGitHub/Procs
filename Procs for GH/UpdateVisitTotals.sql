use `promed`;
drop procedure if exists `UpdateVisitTotals`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `UpdateVisitTotals`(in iaccid bigint)
begin
  /*
  author : johannes
  date : 28 nov 2017
  purpose : to set all totals for the visit / account correctly to there current true values, thus if a receipt is added
  the balanace is adjusted, if new lines FEED adjustments are made (vat wise etc)
  
  need to make decision where update goed to based on if accounted handed over to debtors
  */
  declare vbal decimal(18,2);
  declare vfeebal decimal(18,2);
  declare vvattot decimal(18,2);
  declare vrecipttot decimal(18,2);
  declare vpaidtot decimal(18,2);
  declare linetot integer;
  /*accounts*/
  
  /*
  fExcessAmount
  fBalance
  fVatTotal
  fReceiptTotal
  fPaidTotal
  iLineCount
  tTotalScreenTime
  fTotalRadiationDosage
  
  */
  declare v_bdebtoraccount smallint;
  
	/* on success return 1 , else 0 */
    	    	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[uvt]:',MSG),1,128);   	
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
   
  select bDebtorAccount into v_bdebtoraccount from accounts where ipkAccountID = iaccid;
  select (sum(fPaid) ) into vrecipttot from receipts where ifkaccountID = iaccid; /*- sum(fChange)*/
  
  if (v_bdebtoraccount = 0) then begin
  /*account still at ris side*/
	  select sum(fCost),sum(fPaidAmount),sum(fVATAmount),ifnull(count(ipkFeeID),0) into vbal,vpaidtot,vvattot,linetot 
			from fees where ifkaccountID = iaccid and bFeed  = 1;
	 
	   if (vrecipttot is null) then begin
		 set vrecipttot = 0.0;
	   end; end if;
	   if (vbal is null) then begin
		 set vbal = 0.0;
	   end; end if;
	   if (vpaidtot is null) then begin
		 set vpaidtot = 0.0;
	   end; end if;
	   if (vvattot is null) then begin
		 set vvattot = 0.0;
	   end; end if;
	   if (linetot is null) then begin
		 set linetot = 0;
	   end; end if;
	   set vfeebal =  vbal;
	   set vbal = vbal - vrecipttot;
	  update accounts set fFeedTotal = vfeebal ,fBalance = vbal,fVatTotal = vvattot,
							fReceiptTotal =vrecipttot, fPaidTotal = vpaidtot,iLineCount = linetot 
			where ipkAccountID = iaccid;
  end; end if;  
	if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if;
  
end$$

delimiter ;

