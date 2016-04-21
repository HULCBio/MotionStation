function slObj=xpcsliface(xpcsys)

% XPCSLIFACE - Generates a skeleton Simulink instrumentation model 
%
%   xpcsliface('sys') generates a skeleton Simulink instrumentation model
%   containing To xPC and From xPC blocks based on tagged block parameters
%   and tagged signals from the Simulink system used to build the xPC Target 
%   application. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.1 $  $Date: 2004/04/08 21:05:13 $
     

if ~(ischar(xpcsys))
    error('Argument must be a character array');
    return;
end

srcblks = find_system(xpcsys, 'RegExp', 'on','FollowLinks','on',...
                              'LookUnderMasks','all','Description',...
                              'xPCTag'); %path of all marked blks
porth = find_system(xpcsys, 'RegExp','on','findall','on','FollowLinks',...
                            'on','LookUnderMasks','all','type','port',...
                            'Description','xPCTag');

slObj.taggedSrcBlks=srcblks;                        
slObj.taggedPortObjs=porth;

if (isempty(srcblks) & isempty(porth))
    error(['Can''t generate ',xpcsys,' Simulink instrumnetation model.',...
           ' No tagged xPC signals or block parameters found.']);
    return
end

modelname=xpcsys;
indblkpath=length(xpcsys)+2;
checkpar=0;
checksig=0;
load_system('xpclib');

%------handle model parameters to create To xPC blocks
numofToxpcblks=length(srcblks);
alldescstr=get_param(srcblks,'Description'); 
newmdlname=[xpcsys,'simxpc'];

try
    new_system(newmdlname);
catch
    bdclose(newmdlname);
    new_system(newmdlname);
end

unitstr=get(0,'units');
set(0,'units','pixels');
scsize=get(0,'screensize');
width=scsize(3);height=scsize(4);
loc=get_param(newmdlname,'location');
set_param(newmdlname,'location',[loc(1) loc(2) (3/4)*width loc(4)])

set_param(newmdlname,'StopTime','inf');
set_param(newmdlname,'Solver','FixedStepDiscrete');


errorflag=0;
count=0;

if ~(isempty(srcblks))
    for i=1:numofToxpcblks
        xpcstr=alldescstr{i};
        strind=findstr(xpcstr,'xPCTag');
        endofstrind=findstr(xpcstr,';');
        if (isempty(endofstrind))
            warning backtrace off
            warning(['Can not find end of string character '';'' in marked block: ',srcblks{i},...
                     'ToxPC block(s) can not be added for marked block.']);
             warning backtrace on
            errorflag=1;
        else    
            descstr=xpcstr(strind:endofstrind-1);  %entire marked xpc string
        
            %parse for all parameter index vector
            lbstrind=findstr(descstr,'(');
            rbstrind=findstr(descstr,')');
            vecprmidstr=descstr(lbstrind+1:rbstrind-1);
            vecprmid=str2num(vecprmidstr);
            numofvecprmid=length(vecprmid);
        
            %parse for names for ToxPC block labels
            eqind=findstr(descstr,'=');
            nameliststr = descstr(eqind+1:end);
            if (isempty(nameliststr))
                warning backtrace off
                warning(['Could not detect any block Label names assigned after seperator character ''='' in block:' ,...
                          srcblks{i},'ToxPC block(s) can not be added for marked block.'])
                warning backtrace on
                errorflag=1;
            else    
                nameliststr=deblank(nameliststr);
                namelist=strread(nameliststr,'%s');
                numofnames=length(namelist);
                %get parameters of marked block
                dlgprm=get_param(srcblks{i},'dialogparameters');
                paramlistofblk=fieldnames(dlgprm); %paramlist of marked ToxPC blk
                numofprminblk=length(fieldnames(dlgprm));
    
                %check for misentered formats/parameters of marked blks
                %index of parameters vector must match number of parameters in block
                if (numofvecprmid > numofprminblk)
                    errstr=['Syntax error in Block:  ''',srcblks{i},'''',sprintf('\n')];
                    warning backtrace off
                    warning([errstr,'. The index for Vector pamameter ID(s) exceeds the parameter dimensionsin of block.',...
                            sprintf('\n'),'ToxPC block(s) can not be added for marked block :',srcblks{i}]);
                    warning backtrace on
                   errorflag=1;
                end
                if ~(numofnames == numofvecprmid)
                    errstr=['Syntax error in Block:  ''',srcblks{i},'''',sprintf('\n')];
                    warning backtrace on
                    warning([errstr,'Syntax error found in marked ToxPC block. Block Label names entered does not match vector',...
                                    'pamameter ID(s)',sprintf('\n'),'ToxPC block(s) can not be added for marked block:', srcblks{i}]);
                   warning backtrace off
                    errorflag=1;
                end
                if (find(vecprmid > numofprminblk))
                   errstr=['Syntax error in Block:  ''',srcblks{i},'''',sprintf('\n')];
                   warning backtrace off
                   warning([errstr,'Syntac error found in marekd ToxPC block. Invalid Index vector parameter entered',sprintf('\n'),...
                          'ToxPC block(s) can not be added for marked block:', srcblks{i}]);
                   warning backtrace on
                   errorflag=1;
                end
            end %(isempty(nameliststr))
        end %(isempty(endofstrind))
             %get path to marked blocks. If path contains carriage retruns flatten them out.
        if ~(errorflag)
             if (findstr(sprintf('\n'),srcblks{i}))
                 pathofblk=strrep(srcblks{i},sprintf('\n'),' ');
             else
                 pathofblk=srcblks{i};
             end
             pathofblk=pathofblk(indblkpath:end);
             %add block names
             for j=1:numofnames           
                 count=count+1;
                 add_block('xpclib/Misc./To xPC Target ',[newmdlname,'/',namelist{j}]);
                 set_param([newmdlname,'/',namelist{j}],'appname',modelname);
                 set_param([newmdlname,'/',namelist{j}],'blockpath',pathofblk);
                 set_param([newmdlname,'/',namelist{j}],'paramname',paramlistofblk{vecprmid(j)});
                 Toxpc(count).Namelist=[newmdlname,'/',namelist{j}];
                 Toxpcblk(count).pathofblk=pathofblk;
                 Toxpcblk(count).parameter=paramlistofblk{vecprmid(j)};
             end %end of for j=1:numofnames     
          end %~(errorflag)
          errorflag=0;
      end %for i=1:numofToxpcblks
  else
      disp('No block parameters found to be marked with xPCTag.');
      checkpar=1;
  end %if ~(isempty(srcblks))
  count=0;   
  errorflag=0;
%------handle model signals to create From xPC blocks
compilecom=[xpcsys,'([],[],[],''compile'')'];
termcom=[xpcsys,'([],[],[],''term'')'];
fromxpcsize=get_param('xpclib/Misc./From xPC Target ','Position');
if ~(isempty(porth))
   
    allsigdescstr=cellstr(get_param(porth,'description'));
    numofmarkedfromxpcblks = length(porth);
    try
        evalc(compilecom);
    catch
        evalc(termcom);
        error(lasterr);
    end
    sfunstr=' SFunction ';
    portstr='/p';
    sigstr='/s';
    SF_flag=0;
    count=0;

    for i=1:numofmarkedfromxpcblks
    ActSrcblk=get_param(porth(i),'parent');
    PortNumber=get_param(porth(i),'portnumber');
    Srcblktype=get_param(ActSrcblk,'BlockType');
    msktype=get_param(ActSrcblk,'MaskType');
    
    if ~(strcmpi(msktype,'Stateflow'))
        if (strcmp(Srcblktype,'SubSystem'))
            msgstr=['Marked Ports ''xPCTag'' can only be marked from output ports of Non-Virtual blocks.'];
            warning(msgstr);
            errorflag=1;
        end
        
        line=get_param(porth(i),'line');
        lineDstporth=get_param(line,'DstPortHandle');
        lineDstporth=lineDstporth(find(lineDstporth~=-1));
        porttype=get_param(lineDstporth,'porttype');
        if (strcmpi(porttype,'trigger'))
            warning backtrace off
            warning('Signal tagged for on an invalid Line connection. Marked Signal will be ignored.' );
            warning backtrace on
            errorflag=1;
        end
    elseif (strcmpi(msktype,'Stateflow'))
           statefline=get_param(porth(i),'line');
           SflineDstporth=get_param(statefline,'DstPortHandle');
           porttype=get_param(SflineDstporth,'porttype');
           if (strcmpi(porttype,'trigger'))
               warning backtrace off
               warning('Signal tagged for an invalid Line Stateflow Trigger port. Marked Signal will be ignored.' );
               warning backtrace on
               errorflag=1;
           else
               SF_flag=1;
           end
     end   
    
        %port width info
     Portwidth=get_param(porth(i),'CompiledPortWidth');
     Ports=get_param(ActSrcblk,'Ports');
     NumOutPorts=Ports(2);

     %parse for marked string fromxPC
     sigxpcstr=allsigdescstr{i};
     strsigind=findstr(sigxpcstr,'xPCTag');
     endofstrind=findstr(sigxpcstr,';');
        if (isempty(endofstrind))
            warning backtrace off
            warning(['Syntax Error. Can not find end of string character '';'' on marked signal output of block: ''',...
                      ActSrcblk,''' at Port Number: ',num2str(PortNumber),...
                      sprintf('\n'),'FromxPC block(s) can not be added for marked block.']);
            warning backtrace on
            errorflag=1;
        else    
            marksigstr=sigxpcstr(strsigind:endofstrind-1);
            if (Portwidth == 1)
                lbstrind=findstr(marksigstr,'(');
                rbstrind=findstr(marksigstr,')');
                if (isempty(lbstrind) & (isempty(lbstrind)))
                    vecprmid=1;
                    numofvecprmid=1; 
                else
                    lbstrind=findstr(marksigstr,'(');
                    rbstrind=findstr(marksigstr,')');
                    vecprmidstr=marksigstr(lbstrind+1:rbstrind-1);
                    vecprmid=str2num(vecprmidstr);
                    numofvecprmid=length(vecprmid);
                end
            else       
                %parse signals index vector 
                lbstrind=findstr(marksigstr,'(');
                rbstrind=findstr(marksigstr,')');
                vecprmidstr=marksigstr(lbstrind+1:rbstrind-1);
                vecprmid=str2num(vecprmidstr);
                numofvecprmid=length(vecprmid);                 
            end    
            
            %parse for names for FromxPC block labels
            eqind=findstr(marksigstr,'=');
            nameliststr = marksigstr(eqind+1:end);
            if (isempty(nameliststr))
                warning(['Syntac Error. Could not detect any block Label names assigned after seperator character ''='' in block: ' ,...
                         ActSrcblk,''' at Port Number: ',num2str(PortNumber),...
                        'From xPC block(s) can not be added for marked block.']);
                errorflag=1;
            else    
                nameliststr=deblank(nameliststr);
                namelist=strread(nameliststr,'%s');
                numofnames=length(namelist);
 
               %signal vector index must match portwidth
               if (numofvecprmid > Portwidth)
                  errstr=['Syntax error in marked Signal. The Signal vector index exceeds the signals width'];
                  warning(errstr);
                  errorflag=1;
               end
               if ~(numofnames == numofvecprmid)
                  warning('Syntax error in marked Signal. Block label names entered does not match vector Signal ID(s)');
                  errorflag=1;
               end
               if (find(vecprmid > Portwidth))
                   warning('Syntax error in marked signal. Invalid index vector signal entered');
                   errorflag=1;
               end
           end%(isempty(endofstrind))
           %get path to marked blocks. If path contains carriage retruns flatten them out.
       end  %  (isempty(endofstrind))
       if ~(errorflag)
           if (findstr(sprintf('\n'),ActSrcblk))
               pathofblk=strrep(ActSrcblk,sprintf('\n'),' ');
           else
               pathofblk=ActSrcblk;
           end
   
           pathofblk=pathofblk(indblkpath:end);
           sigblknamelist=repmat({pathofblk},[1 Portwidth]);
 
           for j=1:numofvecprmid
               count=count+1;
               add_block('xpclib/Misc./From xPC Target ',[newmdlname,'/',namelist{j}]);
               set_param([newmdlname,'/',namelist{j}],'appname',modelname);
               signalname=pathofblk;        
               if (SF_flag)
                 signalname=[pathofblk,'/',sfunstr,portstr,num2str(blkout2sfunout(get_param(ActSrcblk,'handle'),PortNumber))];                 
               end
           
               if ~(strcmpi(msktype,'Stateflow'))
                    if (NumOutPorts > 1)
                       signalname=[pathofblk,portstr,num2str(PortNumber)];
                    end               
                    if (Portwidth > 1)
                       signalname=[signalname,'/s',num2str(vecprmid(j))];
                    end
               end %~(strcmpi(msktype,'Stateflow'))
               set_param([newmdlname,'/',namelist{j}],'blockpath',signalname);
               Fromxpc(count).Namelist=[newmdlname,'/',namelist{j}];
               Fromxpc(count).signalname=signalname; 
               fromxpcpos=get_param(Fromxpc(1).Namelist,'Position');
           end    % j=1:numofvecprmid    
           SF_flag=0;
       end % if ~(errorflag)
       errorflag=0;
   end% for i=1:numofmarkedfromxpcblks
   eval(termcom);  
else
    disp('No signals found to be marked with xPCTag ');
    checksig=1;
end %if ~(isempty(srcblks))
reposgenblocks(newmdlname);
set(0,'units',unitstr);
open_system(newmdlname);
set_param(newmdlname,'dirty','on');

function reposgenblocks(newmdlname)
ToxPCblkh=find_system(newmdlname,'findall','on','LookUnderMasks','all','MaskType','dng2xpc');
FromxPCblkh=find_system(newmdlname,'findall','on','LookUnderMasks','all','MaskType','xpc2dng');
unitstr=get(0,'units');
set(0,'units','pixels');
scsize=get(0,'screensize');
width=scsize(3);height=scsize(4);
loc=get_param(newmdlname,'location');
set_param(newmdlname,'location',[loc(1) loc(2) (3/4)*width loc(4)])

delta=0;
if ~isempty(FromxPCblkh)
    for kk=1:length(FromxPCblkh)
        set_param(FromxPCblkh(kk),'position',[15 15+delta 110 15+30+delta])
        delta=delta+50;
    end
end
delta=0;
       
if ~isempty(ToxPCblkh)
    for kk=1:length(ToxPCblkh)
        set_param(ToxPCblkh(kk),'position',[590 15+delta 685 15+30+delta])
        delta=delta+50;
    end
end

%--------------------------------------------------------------------------
