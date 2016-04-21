function [par]=xpctagpt(xpcsys)
% XPCTAGPT - Parses system for Tagged xPC parameters

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/08 21:05:15 $


modelname=xpcsys;
indblkpath=length(xpcsys)+2;
checkpar=0;

%------handle model parameters to create To xPC blocks
srcblks = find_system(xpcsys, 'RegExp', 'on','FollowLinks','on','LookUnderMasks','all','Description','xPCTag'); %path of all marked blks
numofToxpcblks=length(srcblks);
alldescstr=get_param(srcblks,'Description'); %cell str of entire descrption strings of all marked blocks
newmdlname=[xpcsys,'simxpc'];

errorflag=0;
count=0;
track=0;
if (isempty(srcblks))
     disp('No block parameters found to be marked with xPCTag.');
     par=[];    
     return;
end

for i=1:numofToxpcblks
    parTagstr=alldescstr{i};
    ActSrcblk=srcblks{i};
    dlgprm=get_param(ActSrcblk,'dialogparameters');
    paramlistofblk=fieldnames(dlgprm); %paramlist of marked ToxPC blk
    numofprminblk=length(fieldnames(dlgprm));
    parinfo=calcvecptid(parTagstr,ActSrcblk,paramlistofblk,numofprminblk);
    for j=1:length(parinfo)
        track=track+1;
        par(track).parname=parinfo(j).parname;
        par(track).blkpath=parinfo(j).blkpath;
        par(track).comparname=parinfo(j).comparname;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ptinfo=calcvecptid(taggedstr,ActSrcblk,paramlistofblk,numofprminblk)
strsigind=findstr(taggedstr,'xPCTag');
numofTags=length(strsigind);
endofstrind=findstr(taggedstr,';');

 if (findstr(sprintf('\n'),ActSrcblk))
     pathofblk=strrep(ActSrcblk,sprintf('\n'),' ');
 else
     pathofblk=ActSrcblk;
 end
idx=find(pathofblk=='/');
pathofblk=pathofblk(idx(1)+1:end);

if numofTags > 1 %NEW TAGS
   for k=1:numofTags
       sigstrxpc=taggedstr(strsigind(k):endofstrind(k));
       endofind=findstr(sigstrxpc,';');   
       marksigstr=sigstrxpc(strsigind:endofind-1);
       idx=findstr(marksigstr,'(');
       vIdx=marksigstr(idx+1);
       vIdx=str2num(vIdx);
       eqidx=findstr(marksigstr,'=');
       try
           parlab=marksigstr(eqidx+1:end);
           parlab=deblank(parlab);
       catch
          warning('Syntax error in marked signal. No label defined for specified tagged signal.');
          ptinfo(k).parname=[];
          ptinfo(k).blkpath=[];
          ptinfo(k).comparname=[];
      end
      ptinfo(k).parname=paramlistofblk{vIdx};
      ptinfo(k).blkpath=pathofblk;
      ptinfo(k).comparname=parlab;
  end
else
    descstr=taggedstr(strsigind:endofstrind-1);
    if (isempty(endofstrind))
        warning(['Syntax Error. Can not find end of string character '';'' on tagged signal output of block: ''',ActSrcblk,...
                 '. Can not resolve from xPCTag.']);
        ptinfo.comparname=[];        
        ptinfo.blkpath=[];
        ptinfo.Errorflag=1;              
    end 
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
         warning(['Could not detect any block Label names assigned after seperator character ''='' in block:' ,ActSrcblk,...
                  '. Can not resolve from xPCTag.'])
   %      ptinfo.VecId=[];
         ptinfo=[]; 
     end
     nameliststr=deblank(nameliststr);
     namelist=strread(nameliststr,'%s');
     numofnames=length(namelist);
     if (numofvecprmid > numofprminblk)
         errstr=['Syntax error in Block:  ''',ActSrcblk,'''',sprintf('\n')];
         warning([errstr,'. The index for Vector pamameter ID(s) exceeds the parameter dimensionsin.',sprintf('\n'),...
                 'Can not resolve from xPCTag.']);
         ptinfo=[];
         return;
     end
    
     if ~(numofnames == numofvecprmid)
          errstr=['Syntax error in Block:  ''',ActSrcblk,'''',sprintf('\n')];
          warning([errstr,'Block Label names entered does not match Vector pamameter ID(s)',...
                   sprintf('\n'),'Can not resolve from xPCTag']);
        ptinfo=[];
        return;
    end
     
     if (find(vecprmid > numofprminblk))
         errstr=['Syntax error in Block:  ''',ActSrcblk,'''',sprintf('\n')];
                 warning([errstr,' Invalid Index vector parameter entered',sprintf('\n'),...
                         'Can not resolve from xPCTag:']);
        ptinfo=[];
        return;
    end
%  pathofblk=pathofblk(indblkpath:end);
   %add block names
   for j=1:numofnames           
       ptinfo(j).parname=paramlistofblk{vecprmid(j)};
       ptinfo(j).blkpath=pathofblk;
       ptinfo(j).comparname=namelist{j};
   end %end of for j=1:numofnames     
   
end
    


    
    
    
    