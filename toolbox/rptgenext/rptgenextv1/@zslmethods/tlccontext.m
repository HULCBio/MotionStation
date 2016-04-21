function handle=tlccontext(m,sysname)
%TLCCONTEXT gets a TLC server mode context
%   TLCHANDLE=TLCCONTEXT(ZSLMETHODS,MODELNAME)  
%       Each model gets its own TLC context.  This function
%       returns that context handle.  Will create the context
%       if it is not found.  Will return empty if context
%       could not be created.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:57 $

%other syntaxes, planned but not currently supported
%  [HANDLE,ADDRESS]=TLCCONTEXT(Z,SYSTEMNAME,HANDLE)
%  [HANDLE,ADDRESS]=TLCCONTEXT(Z,SYSTEMNAME)

if strcmp(get_param(0,'rtwlicensed'),'on') & exist('tlc','file')>0
   handle=LocGetHandle(bdroot(sysname));
else
   handle=[];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handle=LocGetHandle(mdlName);

try
   tlcHandleList=tlc('list');
   numHandles=length(tlcHandleList);
catch
   tlcHandleList=[];
   numHandles=0;
end

i=1;
handle=[];
while i<=numHandles & isempty(handle)
   try
      ok=strcmp(tlc('get',tlcHandleList(i),'RptgenCaller'),'rptgen');
   catch
      ok=logical(0);
   end
   
   if ok
      try
         ok=strcmp(tlc('get',tlcHandleList(i),'RptgenModel'),mdlName);
      catch
         ok=logical(0);
      end
   end
   
   if ok
      handle=tlchandle(tlcHandleList(i));
   else
      i=i+1;
   end
end

if isempty(handle)
   try
      handle=tlchandle;
      
      execstring(handle,...
         ['%addincludepath "' LocIncludePath '"']);
      
      [aPath aFile aExt]=fileparts(mfilename('fullpath'));
      execfile(handle,[aPath filesep 'temptlc.tlc']);
      
      rtwFileName=[mdlName '.rtw'];
      isExistingRtwFile= ( exist(rtwFileName)==2 );
      
      rtwgen(mdlName);
      read(handle,rtwFileName);
      
      if ~isExistingRtwFile
         delete(rtwFileName);
      end
      set(handle,'RptgenCaller','rptgen');
      set(handle,'RptgenModel',mdlName);
   catch
      warning('Could not compile RTW file for model');
      handle=[];
   end
end

%if isempty(handle) error out?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tlcPath=LocIncludePath

tlcPath=[matlabroot filesep 'rtw' filesep 'c' filesep 'tlc'];
tlcPath=strrep(tlcPath,'\','\\');