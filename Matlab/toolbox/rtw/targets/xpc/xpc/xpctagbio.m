function [sig]=xpctagbio(xpcsys)
% XPCTAGPT - Parses system for Tagged xPC signals

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/08 21:05:14 $

errorflag=0;
count=0;
checksig=0;
sfunstr=' SFunction ';
portstr='/p';
sigstr='/s';
SF_flag=0;
count=0;
counter=0;
warning off backtrace
indblkpath=length(xpcsys)+2;
porth = find_system(xpcsys, 'RegExp','on','findall','on','FollowLinks','on','LookUnderMasks',...
                            'all','type','port','Description','xPCTag');
compilecom=[xpcsys,'([],[],[],''compile'');'];
termcom=[xpcsys,'([],[],[],''term'');'];

if isempty(porth)
   disp('No signals found to be marked with xPCTag ');
   sig=[];
   return
end

try
    evalc(compilecom);
    Prtwdths=get_param(porth,'CompiledPortWidth');
catch
    error(lasterr);
    evalc(termcom);
    return;
end
evalc(termcom);
allsigdescstr=cellstr(get_param(porth,'description'));
numofTagsblks = length(porth);

for i=1:numofTagsblks  %col 1
    ActSrcblk=get_param(porth(i),'parent');
    PortNumber=get_param(porth(i),'portnumber');
    Srcblktype=get_param(ActSrcblk,'BlockType');
    msktype=get_param(ActSrcblk,'MaskType');    
    %handle Stateflow Case blocks...
    if strcmpi(msktype,'Stateflow')%col 5
        statefline=get_param(porth(i),'line');
        SflineDstporth=get_param(statefline,'DstPortHandle');
        porttype=get_param(SflineDstporth,'porttype');
        if (strcmpi(porttype,'trigger'))
            warning('Signal tagged for an invalid Line Stateflow Trigger port. Marked Signal will be ignored.' );
            errorflag=1;
        else
            SF_flag=1;
        end
    end%strcmpi(msktype,'Stateflow')%co, 5
    if ~strcmpi(msktype,'Stateflow') 
         if strcmp(Srcblktype,'SubSystem')
            msgstr=['Marked Ports ''xPCTag'' can only be marked from output ports of Non-Virtual blocks.'];
            warning(msgstr);
            errorflag=1;
         end
         line=get_param(porth(i),'line');
         lineDstporth=get_param(line,'DstPortHandle');
         porttype=get_param(lineDstporth,'porttype');
         if (strcmpi(porttype,'trigger'))
             warning('Signal tagged for on an invalid Line connection. Marked Signal will be ignored.' );
             errorflag=1;
         end
     end%~strcmpi(msktype,'Stateflow')
     
     if length(Prtwdths)==1
         Prtwdths={Prtwdths};
     end
     
     Portwidth=Prtwdths{i};
     Ports=get_param(ActSrcblk,'Ports');
     NumOutPorts=Ports(2);
     %parse for marked string fromxPC
     sigxpcstr=allsigdescstr{i};
     
     SigTagstr=allsigdescstr{i};
 %    strsigind=findstr(sigxpcstr,'xPCTag');
%     numofTags=length(strsigind);
%     endofstrind=findstr(sigxpcstr,';');
     
     %determini Vectorid
     siginfo=calcvecid(SigTagstr,Portwidth,ActSrcblk,PortNumber);
    for j=1:length(siginfo)
        count=count+1;
            if ~(errorflag | isempty(siginfo(j).VecId))
                 if (findstr(sprintf('\n'),ActSrcblk))
                     pathofblk=strrep(ActSrcblk,sprintf('\n'),' ');
                 else
                     pathofblk=ActSrcblk;
                 end
                 pathofblk=pathofblk(indblkpath:end);
                 sigblknamelist=repmat({pathofblk},[1 Portwidth]);
                 signalname=pathofblk;        
                 if (SF_flag)
                    signalname=[pathofblk,'/',sfunstr,portstr,num2str,...
                                blkout2sfunout(get_param(ActSrcblk,'handle'),PortNumber)];
                 end
                 if ~(strcmpi(msktype,'Stateflow'))
                     if (NumOutPorts > 1)
                        signalname=[pathofblk,portstr,num2str(PortNumber)];
                     end               
                     if (Portwidth > 1)
                        signalname=[signalname,'/s',num2str(siginfo(j).VecId)];
                     end
                 end %~(strcmpi(msktype,'Stateflow'))
                 sig(count).comsiglabel=siginfo(j).siglab;
                 sig(count).blkpath=signalname;             
             else
                 sig(count).comsiglabel=[];
                 sig(count).blkpath=[];             
             end % if ~(errorflag)
     end
 end%  i=1:numofTagsblks  col 1
 warning on backtrace
%function------------------------------------------------------------------
function siginfo=calcvecid(taggedstr,sigWidth,ActSrcblk,PortNumber)
warning off backtrace

strsigind=findstr(taggedstr,'xPCTag');
numofTags=length(strsigind);
endofstrind=findstr(taggedstr,';');
     
%determini Vectorid
     
if numofTags > 1 %NEW TAGS
   for k=1:numofTags
       sigstrxpc=taggedstr(strsigind(k):endofstrind(k));
       endofind=findstr(sigstrxpc,';');   
       marksigstr=sigstrxpc(strsigind:endofind-1);
       idx=findstr(marksigstr,'(');
       vIdx=marksigstr(idx+1);
       vIdx=str2num(vIdx);
       eqidx=findstr(marksigstr,'=');
       if (sigWidth==1)
           vIdx=1;
       end
       if isempty(idx) & (sigWidth>1)
           
       end
           
       try
           siglab=marksigstr(eqidx+1:end);
           siglab=deblank(siglab);
       catch
          warning('Syntax error in marked signal. No label defined for specified tagged signal.');
          siginfo(k).VecId=[];
          siginfo(k).siglab=[];
          siginfo(k).Errorflag=1;
      end
       if (isempty(vIdx) & sigWidth>1)
          warning(['Syntax error in marked signal. Invalid index vector signal entered on tagged signal output of block: ''',...
                   ActSrcblk,''' at Port Number: ',num2str(PortNumber),'. Can not resolve from xPC tag.']);
          siginfo(k).VecId=[];
          siginfo(k).siglab=[];          
          siginfo(k).Errorflag=1;
       end
       if (vIdx > sigWidth)
          warning(['Syntax error in marked Signal. The Signal vector index exceeds the signals width']);
          siginfo(k).VecId=[];
          siginfo(k).siglab=[];          
          siginfo(k).Errorflag=1;
       end
       siginfo(k).VecId=vIdx;
       siginfo(k).siglab=siglab;
   end   % for k=1:numofTags      
else             %OLD Tags   
    marksigstr=taggedstr(strsigind:endofstrind-1);
    if (isempty(endofstrind))
        warning(['Syntax Error. Can not find end of string character '';'' on tagged signal output of block: ''',ActSrcblk,...
                 ''' at Port Number: ',num2str(PortNumber),'. Can not resolve from xPC tag.']);
        siginfo.VecId=[];
        siginfo(k).siglab=[];        
        siginfo.Errorflag=1;              
    end

    if (sigWidth == 1) 
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
    
    eqind=findstr(marksigstr,'=');
    nameliststr = marksigstr(eqind+1:end);
    if (isempty(nameliststr))
        warning(['Syntac Error. Could not detect any label(s) defined for specified tagged signals at: ',ActSrcblk,...
                 ''' at Port Number: ',num2str(PortNumber),'. Can not resolve from xPC tag..']);
        siginfo.VecId=[];
        siginfo.siglab=[];        
        siginfo.Errorflag=1; 
    end
 
    nameliststr=deblank(nameliststr);
    namelist=strread(nameliststr,'%s');
    numofnames=length(namelist);
    
    if (numofvecprmid > sigWidth)
        errstr=['Syntax error in marked Signal. The Signal vector index exceeds the signals width'];
        warning(errstr);
        siginfo.VecId=[];
        siginfo.siglab=[];                
        siginfo.Errorflag=1; 
        return
    end
    if ~(numofnames == numofvecprmid)
        warning('Syntax error in marked Signal. Block label names entered does not match vector Signal ID(s)');
        siginfo.VecId=[];
        siginfo.siglab=[];                
        siginfo.Errorflag=1; 
    end
    if (find(vecprmid > sigWidth))
       warning(['Syntax error in marked signal. Invalid index vector signal entered at blcok: ''',ActSrcblk,'.''',...
                sprintf('\n'),'Can not resolve from xPC tag..']);
       siginfo.VecId=[];
       siginfo.siglab=[];               
       siginfo.Errorflag=1; 
       return
   end

   for i=1:numofvecprmid
       siginfo(i).VecId=vecprmid(i);
       siginfo(i).siglab=namelist{i};        
   end
end   %NEW TAGS 

warning on backtrace





