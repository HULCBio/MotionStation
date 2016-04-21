function trackpz(Editor,event)
%TRACKPZ  Tracks compensator pole or zero during mouse drag.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.35.4.2 $  $Date: 2004/04/10 23:14:07 $

persistent MovedGroup PZID Ts Format TransAction InvalidMove
persistent FreqInit Yinit G0 FreqFactor AbsLinMag
persistent ActiveAxes AutoScaleX AutoScaleY
persistent WarnStatus LastMsg LastID

LoopData = Editor.LoopData;
Axes = Editor.Axes;
PlotAxes = getaxes(Axes);
FreqUnits = Axes.XUnits;
MagUnits = Axes.YUnits{1};
PhaseUnits = Axes.YUnits{2};
EventMgr = Editor.EventManager;

% INIT event
if strcmp(event,'init')
   % Initialization for compensator pole/zero drag
   
   % Turn off warning and store last warning 
   WarnStatus = warning('off');
   [LastMsg, LastID] = lastwarn;
   
   Ts = LoopData.Ts;
   Format = Editor.EditedObject.Format;
   FreqFactor = unitconv(1,FreqUnits,'rad/sec');
   
   % Identify selected root
   [MovedGroup,PZID,G0] = LocalGetSelection(gcbo);
   if Ts & MovedGroup.beyondnf(PZID,0.1)
      % Discrete roots beyond Nyquist freq. cannot be moved
      EventMgr.poststatus(sprintf('%s\n%s',...
         'Cannot move roots with natural frequency beyond the Nyquist frequency.',...
         'Use the Root Locus Editor to move such poles/zeros.'));
      InvalidMove = 1;
      return
   else
      InvalidMove = 0;
   end
   
   % Identify selected axes and selected root
   ActiveAxes = find(PlotAxes==handle(gca));
   if ActiveAxes==1
      AbsLinMag = strcmp(MagUnits,'abs') & ...
         strcmp(get(PlotAxes(1),'Yscale'),'linear');
   else
      AbsLinMag = 0;
   end
   
   % Get initial mag/phase data and remove contribution of moved roots 
   FreqInit = Editor.Frequency;   % rad/sec
   if ActiveAxes==1
      Yinit = Editor.Magnitude * getzpkgain(Editor.EditedObject,'mag');  % absolute
   else
      Yinit = (pi/180) * Editor.Phase;   % radians
   end
   Yinit = LocalCancelRoot(ActiveAxes,FreqInit,Yinit,MovedGroup,PZID,Ts,Format);
   FreqInit = FreqInit/FreqFactor;     % initial freqs in current units
   
   % Initialize parameters used to adjust limits/pointer position
   AutoScaleX = strcmp(Axes.XlimMode,'auto');
   AutoScaleY = strcmp(Axes.YlimMode{ActiveAxes},'auto');
   if AutoScaleX | AutoScaleY,
      moveptr(PlotAxes(ActiveAxes),'init');
   end
   
   % Track root location in status bar 
   EventMgr.poststatus(...
      LocalTrackStatus(MovedGroup,PZID,Ts,FreqUnits));
   
   % Broadcast MOVEPZ:init event
   % RE: Sets RefreshMode='quick' and installs listeners on Pole/Zero property of selected group
   LoopData.send('MovePZ',...
      ctrluis.dataevent(LoopData,'MovePZ',{Editor.EditedObject.Identifier,'init',MovedGroup}));
   
   % Start transaction
   TransAction = ctrluis.transaction(LoopData,'Name',sprintf('Move %s',PZID),...
      'OperationStore','on','InverseOperationStore','on','Compression','on');
end

% ACQUIRE and FINISH events
if ~InvalidMove
   switch event
   case 'acquire'
      % Acquire new pole/zero position. 
      % RE: Restrict X position to be in freq. range
      CP = get(PlotAxes(ActiveAxes),'CurrentPoint');
      X = max(FreqInit(1),min(CP(1,1),FreqInit(end)));  
      Y = CP(1,2);
      if AbsLinMag
         Ylim = get(PlotAxes(1),'Ylim');
         Y = max(1e-3*Ylim(2),Y);
      end
      
      % Clear open loop model (stale)
      LoopData.reset('all');
     
      % Compute new p/z position and move pole/zero group
      % RE: Input of MOVEPZ* must be in (rad/sec,abs,rad)
      if ActiveAxes==1
         Y0 = Editor.interpmag(FreqInit,Yinit,X);   % initial mag value at w=X (in abs)
         Y = unitconv(Y,MagUnits,'abs');
         Y = Editor.movepzmag(MovedGroup,PZID,FreqFactor*X,Y,Ts,G0,Y0,Format);
         Y = unitconv(Y,'abs',MagUnits);
      else
         Y0 = interp1(FreqInit,Yinit,X);            % initial phase at w=X (in rad)
         Y = unitconv(Y,PhaseUnits,'rad');
         Y = Editor.movepzphase(MovedGroup,PZID,FreqFactor*X,Y,Ts,G0,Y0,Format);
         Y = unitconv(Y,'rad',PhaseUnits);
      end
      
      % Broadcast PZDataChanged event (triggers plot updates)
      MovedGroup.send('PZDataChanged');
      
      % Track root location in status bar 
      EventMgr.poststatus(...
         LocalTrackStatus(MovedGroup,PZID,Ts,FreqUnits));
      
      % Adjust axis limits if dragged pole/zero gets out of focus
      if AutoScaleX | AutoScaleY,
         % Adjust limits to track mouse motion
         Editor.reframe(PlotAxes(ActiveAxes),X,Y)
      end
      
   case 'finish'
      % Button up event.  Commit and stack transaction
      EventMgr.record(TransAction);
      TransAction = [];   % release persistent objects
      
      % Broadcast MOVEPZ:finish event (exit RefreshMode=quick,...)  
      LoopData.send('MovePZ',...
         ctrluis.dataevent(LoopData,'MovePZ',{Editor.EditedObject.Identifier,'finish'}));
      
      % Update status and command history
      Str = MovedGroup.movelog(PZID,Ts);
      EventMgr.newstatus(sprintf('%s\nRight-click on plots for more design options.',Str));
      EventMgr.recordtxt('history',Str);
      MovedGroup = [];   % release persistent objects
      
      % Trigger global update
      LoopData.dataevent('all');
      
      % Turn warning back on and reset last warning
      warning(WarnStatus);
      lastwarn(LastMsg, LastID);
   end
end

%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%
% LocalGetSelection %
%%%%%%%%%%%%%%%%%%%%%
function [MovedGroup,PZID,G0] = LocalGetSelection(CurrentObj)
% Identifies selected PZGROUP object (pole/zero group)

% Moved PZVIEW object
MovedPZVIEW = getappdata(CurrentObj,'PZVIEW');
if any(MovedPZVIEW.Zero==CurrentObj)
   PZID = 'Zero';
else
   PZID = 'Pole';
end

% Moved PZGROUP
MovedGroup = MovedPZVIEW.GroupData;
G0 = get(MovedGroup);   % initial pole/zero values


%%%%%%%%%%%%%%%%%%%
% LocalCancelRoot %
%%%%%%%%%%%%%%%%%%%
function Y = LocalCancelRoot(MagPhase,Freqs,Y,PZGroup,PZID,Ts,Format)
%  Remove contribution of selected root or groups of roots from magnitude or phase data

%  RE: Convert DT roots to continous time (matched pole/zero conversion).
%      This is warranted by tractability for complex roots and the fact
%      that distorsions will be corrected by REFRESHPZ

s = 1i*Freqs;

% Get zero and pole values (in CT domain)
rz = dom2ct(PZGroup.Zero,Ts);  % zeros
rp = dom2ct(PZGroup.Pole,Ts);  % poles

% Evaluate root contribution  
resp = 1;
switch lower(Format(1))
case 'z'   % zero/pole/gain
   for ct=1:length(rz)
      resp = resp .* (s - rz(ct));
   end
   for ct=1:length(rp)
      resp = resp ./ (s - rp(ct));
   end
case 't'   % time constant
   for ct=1:length(rz)
      resp = resp .* (1 - s/rz(ct));
   end
   for ct=1:length(rp)
      resp = resp ./ (1 - s/rp(ct));
   end
end

% Remove contribution of moved root(s) from Y data
switch MagPhase
case 1  % mag
   Y = Y ./ abs(resp);
case 2  % phase
   Y = Y - atan2(imag(resp),real(resp));
end


%%%%%%%%%%%%%%%%%%%%
% LocalTrackStatus %
%%%%%%%%%%%%%%%%%%%%
function Status = LocalTrackStatus(Group,PZID,Ts,FreqUnits)
% Display info about moved pole/zero

% Defs
Spacing = blanks(5);

switch Group.Type
case 'Notch'
   % Custom display for notch filters
   Text = sprintf('Drag this notch to adjust its depth and natural frequency.');
   [Wn,Zeta] = damp([Group.Zero(1);Group.Pole(1)],Ts);
   Wn = unitconv(Wn,'rad/sec',FreqUnits);
   Status = ...
      sprintf('%s\nNatural Frequency: %0.3g %s%sZero Damping: %0.3g%sPole Damping: %0.3g',...
      Text,Wn(1),FreqUnits,Spacing,Zeta(1),Spacing,Zeta(2));
   
case 'Complex'
   % Complex pair
   Text = sprintf('Drag this %s to the desired location.',lower(PZID));
   R = get(Group,PZID);
   R = R(1);
   [Wn,Zeta] = damp(R,Ts);
   Wn = unitconv(Wn,'rad/sec',FreqUnits);
   Status = ...
      sprintf('%s\nCurrent location: %0.3g %s %0.3gi%sDamping: %0.3g%sNatural Frequency: %0.3g %s',...
      Text,real(R),char(177),abs(imag(R)),Spacing,Zeta,Spacing,Wn,FreqUnits);
   
otherwise
   % Real pole/zero
   Text = sprintf('Drag this %s to the desired location.',lower(PZID));
   R = get(Group,PZID);
   if Ts
      Wn = unitconv(damp(R,Ts),'rad/sec',FreqUnits);
      Status = sprintf('%s\nCurrent location: %0.3g%sNatural Frequency: %0.3g %s',...
         Text,R,Spacing,Wn,FreqUnits);
   else
      Status = sprintf('%s\nCurrent location: %0.3g',Text,R);
   end
end



%%%%%%%%%%
% DOM2CT %
%%%%%%%%%%
function r = dom2ct(r,Ts)
% Returns equivalent continuous-time root
if Ts
   r = log(r)/Ts;
end



