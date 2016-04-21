function [RealTimeData,idxSys] = moveInit(this)
%MOVEINIT  Initializes dynamic update.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/05/04 02:10:18 $

rv = handle([]);
dsL = handle([]);  % SourceChanged listeners for hidden responses
isVisible = false(size(this.Systems));
for v=cat(1,this.PlotCells{:})'
   if strcmp(v.Visible,'off')
      rh = v.Responses;
   else
      rvis = strcmp(get(v.Responses,'Visible'),'on');
      isVisible = isVisible | rvis;
      rv = [rv ; v.Responses(rvis)];  % set of visible responses
      rh = v.Responses(~rvis);  % hidden responses
   end
   L = get(rh,{'DataSrcListener'});
   dsL = [dsL ; cat(1,L{:})];
end

% Visible responses go to quick update mode
set(rv,'RefreshMode','quick')
% Disable listeners to SourceChanged for hidden resp. (speed optim)
set(dsL,'Enable','off')  

% Store key info
RealTimeData = struct('VisibleResponses',rv, ...
   'DataListener',[], 'HiddenResponseListeners',dsL);

% Indices of visible systems (relative to this.Systems)
idxSys = find(isVisible);  
idxSys = idxSys(idxSys<9);  % G and H can't change dynamically