use `promed`;
drop procedure if exists `Log_AccessionExamChange`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `Log_AccessionExamChange`(in iaccession bigint)
begin
	 declare MSG varchar(128);
	 declare exit handler for sqlexception
	 begin 
	 /*need MIN mysql 5.6.4 */
		get diagnostics condition 1 MSG = message_text;
		set MSG = substring(concat('[laec]:',MSG),1,128);   	
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
insert into promed_logs.account_exam_accession_log
(ipkAccountExamAccessionLogID,
AE_ipkAccountExamID,
AE_ifkAccountID,
AE_ifkExamID,
AE_iRef,
AE_iKeep,
AE_iLineNumber,
AE_sSUID,
AE_ifkModalityID,
AE_ifkRoomID,
AE_dExamDate,
AE_tScreenTime,
AE_fRadiationDosage,
AE_ifkAccessionID,
AE_sDosageAreaProduct,
AA_ipkAccessionID,
AA_ifkAccountID,
AA_sAccessionNumber,
AA_ifkAccountFlowStatusID,
AA_sSUID,
AA_dDateEntered,
AA_iLockedBy,
AA_dLockedDate,
AA_ifkAccountFlowGroupID,
AA_iFrozenBy,
AA_bWaiting,
AA_bActive,
AA_bDeleted,
AA_sNote,
AA_ifkCancelledByOperatorsID) (select  0,aelog.ipkAccountExamID,
  aelog.ifkaccountID,
  aelog.ifkExamID,
  aelog.iRef,
  aelog.iKeep,
  aelog.iLineNumber,
  aelog.sSUID,
  aelog.ifkModalityID,
  aelog.ifkRoomID,
  aelog.dExamDate,
  aelog.tScreenTime,
  aelog.fRadiationDosage,
  aelog.ifkaccessionID,
  aelog.sDosageAreaProduct,
  aa.ipkAccessionID,
  aa.ifkaccountID,
  aa.sAccessionNumber,
  aa.ifkAccountFlowStatusID,
  aa.sSUID,
  aa.dDateEntered,
  aa.iLockedBy,
  aa.dLockedDate,
  aa.ifkAccountFlowGroupID,
  aa.iFrozenBy,
  aa.bWaiting,
  aa.bActive,
  aa.bDeleted,
  aa.sNote,
  aa.ifkCancelledByOperatorsID from account_exams aelog, account_accessions aa
  where aelog.ifkaccessionID = aa.ipkAccessionID and aa.ipkAccessionID = iaccession);
       if ((@g_transaction_started = 1) or  (@g_transaction_started = 0) or (@g_transaction_started is null)) then begin
    commit;
     set @g_transaction_started = 0;
      set autocommit = 1;
  end; else begin
    set @g_transaction_started = @g_transaction_started - 1;
  end; end if; 
end$$

delimiter ;

