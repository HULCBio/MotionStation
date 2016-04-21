function varargout=initialize(z,coutlineHandle);
%INITIALIZE sets the Simulink information structure to empty
%   INITIALIZE(ZSLMETHODS) sets up the Simulink information
%   structure with empty fields.
%
%   See also SUBSREF, CLEANUP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:37 $


%initialize(z,'-noinitialize') causes d.Initialized=0;
if nargin > 1
    d.Initialized=~(ischar(coutlineHandle) & strcmp(coutlineHandle,'-noinitialize'));
else
    d.Initialized=1;
end

d.Model=[];
d.System=[];
d.Block=[];
d.Signal=[];

d.MdlCurrSys=[];
d.SysLoopType=[];
d.isMask=[];
d.isLibrary=[];  

d.ReportedSystemList=[];
d.ReportedBlockList=[];
d.ReportedSignalList=[];

d.RtwCompiledModels={};

%d.TlcContext=[]; %The TLC context handle of the current model

d.WordAllList=[];
d.WordVariableList=[];
d.WordFunctionList=[];

%%%%%% Close TEMP_RPTGEN_MODEL %%%%%%%%%%%%
trgm=find_system(0,'SearchDepth',1,...
   'type','block_diagram',...
   'name','temp_rptgen_model');
if length(trgm)>0
   try
      bdclose(trgm);
   end
end


%%%%% List of Open Models %%%%%%%%%%%%%%%
openModels=find_system(0,'SearchDepth',1,...
   'type','block_diagram',...
   'blockdiagramtype','model');

if isempty(openModels)
   openModels=nan;
end

d.PreRunOpenModels=openModels;

%%%% List of Open TLC Context Handles %%%%
%try
%   openContext=tlc('list');
%   if isempty(openContext)
%      openContext=nan;
%   end
%catch
%   openContext=nan;
%end
%d.PreRunOpenTlcContext=openContext;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout==1
   varargout{1}=d;
else
   rgstoredata(z,d);
end