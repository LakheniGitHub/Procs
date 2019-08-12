use `promed`;
drop procedure if exists `SetAccountStatusByRule`;

delimiter $$
use `promed`$$
create definer=`root`@`localhost` procedure `SetAccountStatusByRule`(in vstatusrule varchar(5),
                                in vusername varchar(15), 
                                in vaccountcode varchar(8),
                                in vlocked tinyint,
                                                                in iaccessionid bigint)
begin
/*
  NOTE for reception capturing the and setting status, if status becomes ready then all accesssions under account is set to ready
  this means the status NUMBER is retrieved from the database for the status with sDecription = 'ready' ,if it anything else it wont work
*/
  declare vstatuscode tinyint;
  declare vstatusgroup integer;
    declare vpriority integer;
  declare vcount tinyint;
  declare vcurrentlock int;
  declare vcurrentfreeze int;
  declare vaccountflowstatus tinyint;
  declare vaccountpriority tinyint;
  declare vdoupdate tinyint;
  declare vdoupdateallaccessions tinyint;
  declare vreadystatus integer;
  declare vcancelstatus integer;
  declare vaccessioncount integer;
  declare vaccessionloweststatus  bigint;
  declare vaccessionlowestgroup  bigint;
/*  declare vaccessionauthedcount integer;  */
  
    declare iaccid  bigint;
    declare ioppid  bigint;
    
    select afs.ipkAccountFlowStatusID      into vreadystatus      from   account_flow_statuses afs      where  afs.sDescription = 'READY' ;  
    select afs.ipkAccountFlowStatusID      into vcancelstatus      from   account_flow_statuses afs      where  afs.sDescription = 'CANCELLED' ;  
      
    select ipkAccountID into iaccid from accounts a where   a.sAccountCode = vaccountcode;
    select ipkOperatorID into ioppid from operators o where o.sUserName = vusername;    
    
  set vdoupdate = 0;
  set vdoupdateallaccessions = 0;
  set vaccessioncount = 1;
    
  if (vstatusrule is not null) then     begin
      if (iaccessionid <= 0) then  	
        begin
          select  a.ifkLockedByOperatorsID, 
              a.ifkAccountFlowStatusID,
              a.ifkFrozenByOperatorID
          into  vcurrentlock, 
              vaccountflowstatus,
              vcurrentfreeze
          from accounts a
          where a.ipkAccountID = iaccid;
        end; 
      else   begin
          select  a.iLockedBy, 
              a.ifkAccountFlowStatusID,
              a.iFrozenBy
          into  vcurrentlock, 
              vaccountflowstatus,
              vcurrentfreeze
          from account_accessions a
          where a.ifkaccountID = iaccid 
            and ipkAccessionID = iaccessionid;
			
	     /*select count(*) into vaccessioncount   from account_accessions where 		ifkaccountID = iaccid ;*/
      end; end if;

      select count(afs.ipkAccountFlowStatusID)
      into vcount
      from   account_flow_statuses afs
      where  afs.sStatusRule like vstatusrule;

      select afs.ipkAccountFlowStatusID, afg.ipkAccountFlowGroupID,afs.iPriority
      into   vstatuscode, vstatusgroup,vpriority
      from   account_flow_statuses afs,account_flow_group afg
      where  afs.sStatusRule like vstatusrule 
        and afg.ifkStartingAccountFlowStatusID = afs.ipkAccountFlowStatusID;
      
      if ((vreadystatus = vstatuscode) or (vcancelstatus = vstatuscode)) then begin
         if (iaccessionid <= 0) then begin
            set vdoupdateallaccessions = 1;
         end; end if;
      end; end if;
      
      if ((vcurrentfreeze <> 0) and (vcurrentfreeze is not null)) then   begin 
/*          if (vlocked = 1) then begin*/
              if (  (vcurrentlock <> 0) and (vcurrentlock is not null) and (vcurrentlock <> ioppid)) then begin
                  signal sqlstate '45000'
                  set message_text = "Account is currently locked by another user";
              end; else begin
                  if (vcount <> 0) then begin
                      set vdoupdate = 1;
                  end; end if;
              end; end if;
/*          end; else begin
              if (vcount <> 0) then begin
                  set vdoupdate = 1;
              end; end if;
          end; end if;
*/          
	  end; else begin
          /*if (vlocked = 1) then begin*/
              if (  (vcurrentlock <> 0) and (vcurrentlock is not null)  and (vcurrentlock <> ioppid)) then begin
                  signal sqlstate '45000'
                  set message_text = "Account is currently locked by another user";
			  end; else begin 
					if (vcount <> 0) then  begin
                      set vdoupdate = 1;
					end; end if;
			  end; end if;
          /*end; else begin

              if (vcount <> 0) then 
                begin

                  set vdoupdate = 1;
                end; 
              end if;
          end; end if;*/
	  end; end if;
  end; end if;
  
  if (vdoupdate = 1) then 
    begin

      if (iaccessionid <= 0) then 
        begin 

          update accounts a
            set a.ifkAccountFlowStatusID = vstatuscode,
              a.ifkAccountFlowGroupID = vstatusgroup
          where  a.ipkAccountID = iaccid;
          
          if (vdoupdateallaccessions = 1) then begin
			  update account_accessions a
				set a.ifkAccountFlowStatusID = vstatuscode,
				  a.ifkAccountFlowGroupID = vstatusgroup
			      where  a.ifkaccountID = iaccid and ifkAccountFlowStatusID < vstatuscode;
              
              update visit v
              set v.dDateEnd = current_timestamp
              where  v.ifkaccountID = iaccid;
          end; end if;      

          /* cant do on account level now, must be per accession
          update visit v,accounts a
            set v.dDateEnd = current_timestamp
          where  a.ipkAccountID = v.ifkaccountID and a.ifkaccountID = iaccid;
          */

          update operators o
            set o.ifkCurrentAccountID = null
          where  o.ifkCurrentAccountID = iaccid;

          delete oa 
          from   operator_accounts oa
          where  oa.ifkaccountID = iaccid ;

          if (vstatusrule = 'AUT') then
            update accounts a
              set a.sPrimaryCustomDoctor = '1',
                a.bWaiting = 0
            where  a.ipkAccountID = iaccid;
			call accountauth(iaccid,null,ioppid);
            if (vdoupdateallaccessions = 1) then begin
				update account_accessions a
				set  a.bWaiting = 0
				where  a.ifkaccountID = iaccid ;
				
            end; end if;
          end if;
          

          if (vstatusrule = 'TEC') then
            begin

              select ap.iPriority
              into vaccountpriority
              from account_priorities ap
              where ap.ifkaccountID = iaccid ;

              if (vaccountpriority <= 1) then
                begin

                  if exists (select ap.ipkAccountPriorityID 
                        from account_priorities ap 
                        where  ap.ifkaccountID = iaccid) then 
                    begin

                      update account_priorities ap
                        set ap.iPriority = vaccountpriority,
                          ap.iLookAtTimePeriods =  0
                      where ap.ifkaccountID = iaccid;
                    end;
                  else 
                    begin

                      insert into account_priorities (ifkaccountID,iPriority,iLookAtTimePeriods)
                      values(iaccid,4,0);
                    end; 
                  end if;
                end;
              end if;
            end;
          end if;

          if (vstatusrule = 'RET') then 
            begin

              /* has to be per accession now
              update visit v,accounts a
                set v.ifkRadiologistOperatorID = null
              where a.ipkAccountID = v.ifkaccountID and a.ifkaccountID = iaccid;*/

              if exists (select ap.ipkAccountPriorityID
                    from account_priorities ap 
                    where ap.ifkaccountID = iaccid ) then 
                begin

                  update account_priorities ap
                    set ap.iPriority = vpriority,
                      ap.iLookAtTimePeriods =  0
                  where ap.ifkaccountID = iaccid;
                end; 
              else 
                begin

                  insert into account_priorities (ifkaccountID,iPriority,iLookAtTimePeriods)
                  values(iaccid,vpriority,0);
                end; 
              end if;
            end; 
          end if; 
        end; 
      else 
        begin
          update account_accessions a
            set a.ifkAccountFlowStatusID = vstatuscode,
              a.ifkAccountFlowGroupID = vstatusgroup
          where  a.ifkaccountID = iaccid 
            and ipkAccessionID = iaccessionid;

         /* if (vaccessioncount = 1) then begin 
			  update accounts a
				set a.ifkAccountFlowStatusID = vstatuscode,
				  a.ifkAccountFlowGroupID = vstatusgroup
			  where  a.ipkAccountID = iaccid;
		  end; end if;	
		  */
		  select min(ifkAccountFlowStatusID) into vaccessionloweststatus from account_accessions where ifkaccountID = iaccid;
		  select min(ifkAccountFlowGroupID) into vaccessionlowestgroup from account_accessions where ifkaccountID = iaccid and ifkAccountFlowStatusID = vaccessionloweststatus;
		  
		  update accounts a
				set a.ifkAccountFlowStatusID = vaccessionloweststatus,
				  a.ifkAccountFlowGroupID = vaccessionlowestgroup
			  where  a.ipkAccountID = iaccid;
		  
          update visit v
            set v.dDateEnd = current_timestamp
          where  v.ifkaccountID = iaccid 
            and ifkaccessionID = iaccessionid;

          update operators o
            set o.ifkCurrentAccountID = null, ifkCurrentAccessionID = null
          where  o.ifkCurrentAccountID = iaccid 
            and ifkCurrentAccessionID = iaccessionid;

          delete oa 
          from   operator_accounts oa
          where  oa.ifkaccountID = iaccid 
            and oa.ifkaccessionID = iaccessionid;

          if (vstatusrule = 'AUT') then

            update account_accessions a
              set  a.bWaiting = 0
            where  a.ifkaccountID = iaccid 
              and ipkAccessionID = iaccessionid;
			  call accountauth(iaccid,iaccessionid,ioppid);
			  
			   /*select count(*) into vaccessionauthedcount from account_accessions a
						where a.ifkAccountFlowStatusID = vstatuscode 
								and a.ifkAccountFlowGroupID = vstatusgroup 
								and a.ifkaccountID = iaccid;
								
			  if (vaccessionauthedcount = vaccessioncount) then begin
					  update accounts a
					  set a.sPrimaryCustomDoctor = '1',
						a.bWaiting = 0
					where  a.ipkAccountID = iaccid;
					call accountauth(iaccid,null,ioppid);
			  end; end if;
			  */
          end if;
      
          if (vstatusrule = 'TEC') then
            begin

              select ap.iPriority
              into vaccountpriority
              from account_priorities ap
              where ap.ifkaccountID = iaccid ;

              if (vaccountpriority <= 1) then
                begin

                  if exists (select ap.ipkAccountPriorityID
                        from account_priorities ap 
                        where ap.ifkaccountID = iaccid) then 
                    begin

                      update account_priorities ap
                        set ap.iPriority = vaccountpriority,
                          ap.iLookAtTimePeriods =  0
                      where ap.ifkaccountID = iaccid;
                    end;
                  else 
                    begin

                      insert into account_priorities (ifkaccountID,iPriority,iLookAtTimePeriods)
                      values(iaccid,4,0);
                    end; 
                  end if;
                end;
              end if;
            end;
          end if;

          if (vstatusrule = 'RET') then 
            begin

              update visit v
                set v.ifkRadiologistOperatorID = null
              where v.ifkaccountID = iaccid 
                and ifkaccessionID = iaccessionid;

              if exists (select ap.ipkAccountPriorityID
                    from account_priorities ap 
                    where ap.ifkaccountID = iaccid ) then 
                begin

                  update account_priorities ap
                    set ap.iPriority = vpriority,
                      ap.iLookAtTimePeriods =  0
                  where ap.ifkaccountID = iaccid;
                end; 
              else 
                begin

                  insert into account_priorities (ifkaccountID,iPriority,iLookAtTimePeriods)
                  values(iaccid,vpriority,0);
                end; 
              end if;
            end; 
          end if;     
        end; 
      end if;   
    end; 
  end if;                   
end$$

delimiter ;

