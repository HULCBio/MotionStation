function trackgain(Editor,action)
%TRACKGAIN  Keeps track of gain value while dragging mag curve.
%
%   See also SISOTOOL

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.38.4.2 $  $Date: 2004/04/10 23:14:06 $

persistent FreqData TransAction GainInfo AbsLinMag ResetOption
persistent WarnStatus LastMsg LastID

LoopData = Editor.LoopData;
MagAx = getaxes(Editor.Axes);  MagAx = MagAx(1);
MagUnits = Editor.Axes.YUnits{1};
EventMgr = Editor.EventManager;

% Process ACTION
switch action 
   
case 'init'
   % Turn off warning and store last warning 
   WarnStatus = warning('off');
   [LastMsg, LastID] = lastwarn;    
    
   % Initialize persistent
   GainInfo = Editor.describe('gain');
   ResetOption = sprintf('gain%s',Editor.EditedObject.Identifier);
   FreqData = unitconv(Editor.Frequency,'rad/sec',Editor.Axes.XUnits);
   AbsLinMag = strcmp(MagUnits,'abs') & strcmp(get(MagAx,'Yscale'),'linear');
   
   % Initialize parameters used to adjust mag limits
   Editor.EditModeData = [];
   Editor.slidelims('init',getzpkgain(Editor.EditedObject,'mag'),'mousetrackon');
   
   % Broadcast MOVEGAIN:init event
   % RE: Sets RefreshMode='quick' and attaches listener to Gain data changes
   LoopData.send('MoveGain',...
      ctrluis.dataevent(LoopData,'MoveGain',{Editor.EditedObject.Identifier,'init'}));
   EventMgr.poststatus(...
      sprintf('Drag the magnitude curve up or down to change the %s.',GainInfo));
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name','Edit Gain',...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
   
case 'acquire'
   % Clear dependent information
   LoopData.reset(ResetOption)
   
   % Acquire new gain value during drag.
   % RE: Restrict X position to be in freq. data range 
   CP = get(MagAx,'CurrentPoint');
   X = max(FreqData(1),min(CP(1,1),FreqData(end)));
   Y = CP(1,2);
   if AbsLinMag
      Ylim = get(MagAx,'Ylim');
      Y = max(1e-3*Ylim(2),Y);
   end
   
   % Get new gain value (interpolate in plot units to limit distorsions)
   NewGain = unitconv(Y,MagUnits,'abs') / ...
      Editor.interpmag(FreqData,Editor.Magnitude,X);
   
   % Update Y limits
   Editor.slidelims('update',NewGain,X,Y);
   
   % Update loop data (triggers plot update via listeners installed by refreshgain)
   Editor.EditedObject.setzpkgain(NewGain,'mag');
   
case 'finish'
   % Button up event.  Commit and stack transaction
   EventMgr.record(TransAction);
   TransAction = [];   % release persistent objects
   
   % Broadcast MOVEGAIN:finish event (exit RefreshMode=quick,...) 
   LoopData.send('MoveGain',...
      ctrluis.dataevent(LoopData,'MoveGain',{Editor.EditedObject.Identifier,'finish'}));
   
   % Update status and command history
   GainInfo(1) = upper(GainInfo(1));
   Str = sprintf('%s changed to %0.3g',GainInfo,getgain(Editor.EditedObject));
   EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
   EventMgr.recordtxt('history',Str);
   
   % Trigger global update
   LoopData.dataevent(sprintf('gain%s',Editor.EditedObject.Identifier));
   
   % Turn warning back on and reset last warning
   warning(WarnStatus);
   lastwarn(LastMsg, LastID);
   
end

