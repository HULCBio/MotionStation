function update(Editor,varargin)
%UPDATE  Updates Root Locus Editor and regenerates plot.

%   Author(s): Karen D. Gondoly
%              P. Gahinet (UDD)
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.68 $  $Date: 2002/06/11 17:29:39 $

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off')
   % Editor is inactive
   return
end

% Model data
LoopData = Editor.LoopData;
Ts = LoopData.Ts;  % sample time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update Frequency Response Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get normalized open-loop (for compensator gain mag=1)
NormOpenLoop = getopenloop(Editor.LoopData);
Editor.SingularLoop = (~isfinite(NormOpenLoop));
if Editor.SingularLoop
   % Open loop is not defined, e.g., when minor loop cannot be closed in config 4
   Editor.clear;  return
end
GainMag = getzpkgain(Editor.EditedObject,'mag');

% Compute Bode response for adequate freq. grid (units = rad/sec,abs,degrees)
lwarn = lastwarn; warn = warning('off');
[Editor.Magnitude,Editor.Phase,Editor.Frequency,FreqFocus] = ...
   bode(Editor,{NormOpenLoop});
warning(warn);lastwarn(lwarn);

% Conversion factors
FreqConvert = unitconv(1,'rad/sec',Editor.Axes.XUnits);
MagData = unitconv(GainMag * Editor.Magnitude,'abs',Editor.Axes.YUnits{1});
PhaseData = unitconv(Editor.Phase,'deg',Editor.Axes.YUnits{2});
if Ts
   NyqFreq = FreqConvert * pi/Ts;
else 
   NyqFreq = NaN;
end

% Resolve undetermined focus (quasi-integrator)
if isempty(FreqFocus)
   % Look for 0dB gain crossings to anchor focus
   UnitGain = unitconv(1,'abs',Editor.Axes.YUnits{1});
   idxc = find((MagData(1:end-1)-UnitGain).*(MagData(2:end)-UnitGain)<=0);
   if ~isempty(idxc)
      idxc = idxc(round(end/2));
      FreqFocus = [Editor.Frequency(idxc)/10 , 10*Editor.Frequency(idxc+1)];
   elseif Ts
      FreqFocus = NyqFreq * [0.05,1];
   else
      FreqFocus = [0.1,1];
   end
end

% Set preferred frequency range
Editor.FreqFocus = FreqFocus;

%%%%%%%%%%%%%
% Render Data
%%%%%%%%%%%%%
HG = Editor.HG;
PlotAxes = getaxes(Editor.Axes);
Style = Editor.LineStyle;
UIC = get(PlotAxes(1),'uicontextmenu'); % axis ctx menu

% Clear HG objects managed by Bode editor
Editor.clear;

% Plot the fixed poles and zeros
[FixedZeros,FixedPoles] = fixedpz(LoopData);
if strcmp(Editor.ShowSystemPZ,'on')
   MagPZVis = Editor.MagVisible;
   PhasePZVis = Editor.PhaseVisible;
else
   MagPZVis = 'off';
   PhasePZVis = 'off';
end
Zlevel = Editor.zlevel('system');

% System zeros 
FixedZeros = [FixedZeros(~imag(FixedZeros),:) ; FixedZeros(imag(FixedZeros)>0,:)];
FreqZ = FreqConvert * damp(FixedZeros,Ts);
MagZ = [];  PhaseZ = [];
if Ts,
   % Discard roots whose CT frequency exceeds pi/Ts
   idx = find(FreqZ<=NyqFreq);
   FixedZeros = FixedZeros(idx);
   FreqZ = FreqZ(idx);
end
ZProps = {...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','o','MarkerSize',5,...
      'Color',Style.Color.System,...
      'UIContextMenu',UIC,...
      'HelpTopicKey','sisosystempolezero',...
      'ButtonDownFcn',{@LocalShowData Editor}}; 
for ct=length(FixedZeros):-1:1
   MagZ(ct,1) = line(FreqZ(ct),NaN,Zlevel,...
      'Parent',PlotAxes(1),'UserData',FixedZeros(ct),'Visible',MagPZVis,ZProps{:});
   PhaseZ(ct,1) = line(FreqZ(ct),NaN,Zlevel,...
      'Parent',PlotAxes(2),'UserData',FixedZeros(ct),'Visible',PhasePZVis,ZProps{:});
end
imfz = find(imag(FixedZeros)>0);
set([MagZ(imfz,:);PhaseZ(imfz,:)],'LineWidth',2)

% System poles
FixedPoles = [FixedPoles(~imag(FixedPoles),:) ; FixedPoles(imag(FixedPoles)>0,:)];
FreqP = FreqConvert * damp(FixedPoles,Ts);
MagP = [];  PhaseP = [];
if Ts,
   % Discard roots whose CT frequency exceeds pi/Ts
   idx = find(FreqP<=NyqFreq);
   FixedPoles = FixedPoles(idx);
   FreqP = FreqP(idx);
end
PProps = {...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle','none','Marker','x','MarkerSize',6,...
      'Color',Style.Color.System,...
      'UIContextMenu',UIC,...
      'HelpTopicKey','sisosystempolezero',...
      'ButtonDownFcn',{@LocalShowData Editor}};
for ct=length(FixedPoles):-1:1
   MagP(ct,1) = line(FreqP(ct),NaN,Zlevel,...
      'Parent',PlotAxes(1),'UserData',FixedPoles(ct),'Visible',MagPZVis,PProps{:});
   PhaseP(ct,1) = line(FreqP(ct),NaN,Zlevel,...
      'Parent',PlotAxes(2),'UserData',FixedPoles(ct),'Visible',PhasePZVis,PProps{:});
end
imfp = find(imag(FixedPoles)>0);
set([MagP(imfp,:);PhaseP(imfp,:)],'LineWidth',2)

% Handle summary
HG.System.Magnitude = [MagZ;MagP];
HG.System.Phase = [PhaseZ;PhaseP];

% Plot the Bode diagrams
FreqData = FreqConvert * Editor.Frequency;
Zdata = Editor.zlevel('curve',[length(FreqData) 1]);
HG.BodePlot(1,1) = line(FreqData,MagData,Zdata,...
   'Parent',PlotAxes(1), ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Visible',Editor.MagVisible, ...
   'Color',Style.Color.Response,...
   'UIContextMenu',UIC,...
   'HelpTopicKey','sisobode',...
   'Tag',xlate('Open-loop magnitude plot.'),...
   'ButtonDownFcn',{@LocalMoveGain Editor 'init'});  
HG.BodePlot(2,1) = line(FreqData,PhaseData,Zdata,...
   'Parent',PlotAxes(2), ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Visible',Editor.PhaseVisible, ...
   'Color',Style.Color.Response,...
   'HelpTopicKey','sisobode',...
   'Tag',xlate('Open-loop phase plot.'),...
   'UIContextMenu',UIC); 

% Update portion of Bode plot to be included in limit picking
% REVISIT: Simply set BodePlot's XlimIncludeData property when available
XFocus = getfocus(Editor);
InFocus = find(Editor.Frequency >= XFocus(1) & Editor.Frequency <= XFocus(2));
set(HG.BodeShadow(1),...
   'XData',FreqData(InFocus),'YData',MagData(InFocus),'ZData',zeros(size(InFocus)))
set(HG.BodeShadow(2),...
   'XData',FreqData(InFocus),'YData',PhaseData(InFocus),'ZData',zeros(size(InFocus)))

% Update HG database
Editor.HG = HG;

% Adjust X position of Nyquist lines
Editor.setnyqline(NyqFreq)

% Plot the compensator poles and zeros, and set Y coordinates of 
% poles/zeros to attach them to Bode curves
plotcomp(Editor)
Editor.interpy(MagData,PhaseData);

% Stability margins
showmargin(Editor)

% Update axis limits
% RE: Includes line handle restacking for proper layering
updateview(Editor)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowData %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalShowData(hSrc,event,Editor)
% Show system data
if ~strcmp(Editor.EditMode,'idle')
   % Redirect to editor axes
   Editor.mouseevent('bd',get(hSrc,'parent'));
elseif strcmp(get(gcbf,'SelectionType'),'open')
   Editor.root.send('ShowData');  % notify parent of open request
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(hSrc,event,Editor,action)
% Callback for button down on closed-loop poles
% REVISIT: merge with trackgain when directed callback are available
persistent SISOfig WBMU

switch action
case 'init'
   % Initialize move
   SISOfig = gcbf;
   if ~strcmp(Editor.EditMode,'idle')
      % Redirect to editor axes
      Editor.mouseevent('bd',get(hSrc,'parent'));
   elseif strcmp(get(SISOfig,'SelectionType'),'normal')
      % Change pointer
      setptr(SISOfig,'closedhand')
      % Take over window mouse events
      WBMU = get(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'});
      set(SISOfig,'WindowButtonMotionFcn',{@LocalMoveGain Editor 'acquire'},...
         'WindowButtonUpFcn',{@LocalMoveGain Editor 'finish'});
      % Initialize tracking algorithm and notify peers
      Editor.trackgain('init');
   end
case 'acquire'
   % Track mouse location (move)
   Editor.trackgain('acquire');
case 'finish'
   % Restore initial conditions
   set(SISOfig,{'WindowButtonMotionFcn','WindowButtonUpFcn'},WBMU,'Pointer','arrow')
   % Clean up and update
   Editor.trackgain('finish');
end
