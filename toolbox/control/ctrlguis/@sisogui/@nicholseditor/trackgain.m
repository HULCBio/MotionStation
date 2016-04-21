function trackgain(Editor, action, varargin)
%  TRACKGAIN  Keeps track of gain value while dragging Nichols curve.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.22.4.2 $ $Date: 2004/04/10 23:14:13 $

persistent TransAction InitFreq GainInfo
persistent InitMag Phase Frequency ResetOption
persistent WarnStatus LastMsg LastID

LoopData = Editor.LoopData;
PlotAxes = getaxes(Editor.Axes); 
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
   
   % Nichols plot data in current units
   [OldGain, Magnitude, Phase, Frequency] = nicholsdata(Editor);
   
   % Initial mouse position
   CP = get(PlotAxes, 'CurrentPoint');
   X = max(min(Phase), min(CP(1,1), max(Phase)));
   Y = CP(1,2);
   
   % Initial freq. at the point closest to the mouse position, in current units.
   InitFreq = Editor.project(X, Y, Phase, Magnitude, Frequency);
   InitMag  = 20*log10(Editor.interpmag(Frequency, Editor.Magnitude, InitFreq));
   
   % Initialize parameters used to adjust mag limits
   Editor.EditModeData = [];
   Editor.slidelims('init', OldGain, 'mousetrackon');
   
   % Broadcast MOVEGAIN:init event
   % RE: Sets RefreshMode = 'quick' and attaches listener to Gain data changes
   LoopData.send('MoveGain', ctrluis.dataevent(LoopData, 'MoveGain', ...
      {Editor.EditedObject.Identifier, 'init'}));
   EventMgr.poststatus(sprintf(['Drag the Nichols curve up or down to ', ...
         'change the %s.\n%s.'], GainInfo, Editor.pointerlocation));
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name','Edit Gain',...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
   
case 'acquire'
   % Clear dependent information
   LoopData.reset(ResetOption)
   
   % Acquire new gain value during drag.
   CP = get(PlotAxes, 'CurrentPoint');
   Xmin = min(Phase); Xmax = max(Phase);
   Xbnd = 0.01 * (Xmax-Xmin); % 1 percent X motion limits at the edges
   X = max(Xmin+Xbnd, min(CP(1,1), Xmax-Xbnd)); % Range of X motion
   Y = CP(1,2);
   
   % Interpolate mouse X-position using phase data
   [index, alpha] = interppha(Editor, Phase, X);
   
   % Get the frequency data
   Freq = alpha .* Frequency(index+1) + (1-alpha) .* Frequency(index);
   [junk,I] = min(abs(Freq - InitFreq));
   
   % Get new gain value (interpolate in plot units to limit distorsions)
   NewMag = 20*log10(Editor.interpmag(Frequency, Editor.Magnitude, Freq(I)));
   Jump = 10; % Limit maximum jump/change in dB in a single step
   if abs(NewMag-InitMag) > Jump;
      InitMag = InitMag + Jump * sign(NewMag-InitMag);
      NewGain = 10.^((Y-InitMag)/20);
   else
      NewGain = 10.^((Y-NewMag)/20);
   end
   
   % Update Y limits
   Editor.slidelims('update', NewGain, CP(1,1), Y);
   
   % Update loop data (triggers plot update via listeners by refreshgain)
   Editor.EditedObject.setzpkgain(NewGain, 'mag');
   
   EventMgr.poststatus(sprintf(['Drag the Nichols curve up or down to ', ...
         'change the %s.\n%s.'], GainInfo, Editor.pointerlocation));
   
case 'finish'
   % Button up event.  Commit and stack transaction
   EventMgr.record(TransAction);
   TransAction = [];   % release persistent objects
   
   % Broadcast MOVEGAIN:finish event (exit RefreshMode = quick, ...) 
   LoopData.send('MoveGain', ctrluis.dataevent(LoopData, 'MoveGain', ...
      {Editor.EditedObject.Identifier, 'finish'}));
   
   % Update status and command history
   GainInfo(1) = upper(GainInfo(1));
   Str = sprintf('%s changed to %0.3g', GainInfo, ...
      getgain(Editor.EditedObject));
   EventMgr.newstatus(sprintf(['%s\nRight-click on plots for more ', ...
         'design options.'], Str));
   EventMgr.recordtxt('history',Str);
   
   % Trigger global update
   LoopData.dataevent('gainC');
   
   % Turn warning back on and reset last warning
   warning(WarnStatus);
   lastwarn(LastMsg, LastID);
   
end
