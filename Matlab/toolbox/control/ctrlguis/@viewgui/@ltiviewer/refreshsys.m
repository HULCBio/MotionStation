function refreshsys(this)
%REFRESH  Refresh systems in LTI Viewer.

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/05/18 02:28:37 $

this.EventManager.newstatus('Refreshing systems...');
set(this.Figure,'Pointer','watch');

%---Check status of systems vs workspace
SystemNames = get(this.Systems,{'Name'});
[NewValues,Status] = systemstat(this,this.Systems);
IdxDiffSize = find(Status==0);  % systems with changed I/O size
if ~isempty(IdxDiffSize)
   Msg = cat(1,...
      {'The following systems have a different number of';...
         'inputs and/or outputs than those currently displayed:';...
         ''},...
      strcat({'     '},SystemNames(IdxDiffSize)),...
      {'';...
         ''});
   if strcmp(questdlg(Msg,'LTI Viewer Refresh','Continue','Cancel','Continue'),'Cancel')
      this.EventManager.newstatus('Refresh canceled.');
      set(this.Figure,'Pointer','arrow')
      return
   end
end

% Skip systems that are no longer in the workspace
IdxUndef = find(Status<0);
if ~isempty(IdxUndef)
   Msg = cat(1,...
         {'The following systems are no longer in the Workspace:';...
          ''},...
          strcat({'     '},SystemNames(IdxUndef)));
   warndlg(Msg,'LTI Viewer Warning','modal');  
end 
SystemNames(IdxUndef) = [];
NewValues(IdxUndef) = [];

% Update viewer
importsys(this,SystemNames,NewValues)
this.EventManager.newstatus('All systems in the Workspace have been updated.');
set(this.Figure,'Pointer','arrow')

%%%%%%%%%%%%%%%%%%%
% Local Functions %
%%%%%%%%%%%%%%%%%%%
function [NewValues,Status] = systemstat(this,Systems)
%SYSTEMSTAT  Check workspace status of systems
% Check workspace status of systems given by SystemNames
% Status key:
%     -1  ->  System has been deleted
%      0  ->  System exists, but has different I/O size
%      1  ->  System exists and is correct size
N = length(Systems);
NewValues = cell(N,1);
Status = zeros(N,1);
for ct = 1:N
    Size = size(Systems(ct).Model);
    NewVal = evalin('base',Systems(ct).Name,'[]');
    SizeNewVal = size(NewVal);
    if ~(isa(NewVal,'lti')||isa(NewVal,'idmodel')||isa(NewVal,'idfrd'))
        % No longer in workspace
        Status(ct) = -1;
    elseif ((isa(NewVal,'lti') & isequal(Size,SizeNewVal)) | ...
            ((isa(NewVal,'idmodel')|isa(NewVal,'idfrd')) & isequal(Size(1:2),SizeNewVal(1:2))))
        Status(ct) = 1;
    end
    NewValues{ct} = NewVal;
end