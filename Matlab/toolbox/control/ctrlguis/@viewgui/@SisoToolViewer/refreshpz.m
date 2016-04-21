function refreshgain(this,action,varargin)
%REFRESHGAIN  Refreshes plot during dynamic edit of compensator gain.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/03 04:14:55 $

%RE: Do not use persistent variables here (several viewers
%    might track gain changes in parallel).

switch action
case 'init'
    % Initialization for dynamic gain update (drag).
   [RealTimeData,idxSys] = moveInit(this);
   
   % Install listener on compensator gain
   RespList = resplist(this.Parent);
   PZGroup = varargin{1};    % Modified PZGROUP (C or F)
   RealTimeData.DataListener = handle.listener(PZGroup,'PZDataChanged',...
      {@LocalUpdatePlot this.Parent.LoopData this.Systems(idxSys) RespList(idxSys,1)});
    
   % Save data need for clean up (moveFinish)
   this.RealTimeData = RealTimeData;
   
case 'finish'
   % Return editor's RefreshMode to normal
   moveFinish(this)
   this.RealTimeData = [];
   
   % Clear data cached in lti sources
   resetsys(this)
end


%-------------------------Local Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdatePlot %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdatePlot(hSrcProp,event,LoopData,VisibleSystems,VisibleSystemAlias)
% Updates visible models (SourceChanged listeners will do the rest)
ModelData = looptransfers(LoopData,VisibleSystemAlias);
for ct=1:length(VisibleSystems)
   VisibleSystems(ct).Model = ModelData{ct};
end