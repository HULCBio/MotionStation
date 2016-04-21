function refreshpzF(Editor,event,varargin)
%REFRESHPZF  Refreshes plot during dynamic edit of F's poles and zeros.
%
%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/06/11 17:29:58 $

% Only need to update rleditor if filter forms a minor-loop
if Editor.LoopData.Configuration~=4 
    return
end

% Process events
switch event 
case 'init'   
   % Initialization for dynamic gain update (drag).
   PZGroup = varargin{1};    % Modified PZGROUP
   
   % Switch editor's RefreshMode to quick
   Editor.RefreshMode = 'quick';
   
   % Gain values for root locus refreshing
   if isempty(Editor.LocusGains)
      UpdateGains = zeros(1,0);
   else
      nGains = 25;  
      MinGain = log10(Editor.LocusGains(2));
      MaxGain = log10(Editor.LocusGains(end-2));
      UpdateGains = [Editor.LocusGains(1) , ...
            logspace(MinGain,max(MinGain+1,MaxGain),nGains) , ...
            Editor.LocusGains(end-1:end)];
   end
   
   % Install listener on PZGROUP data
   L = handle.listener(PZGroup,'PZDataChanged',{@refreshplot UpdateGains 1});
   L.CallbackTarget = Editor;
   Editor.EditModeData = L;
   
case 'finish'
   % Clean up after dynamic gain update (drag)
   % Return editor's RefreshMode to normal
   Editor.RefreshMode = 'normal';
   
   % Delete listener
   delete(Editor.EditModeData);
   Editor.EditModeData = [];
end

