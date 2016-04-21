function update(Editor,varargin)
%UPDATE  Updates Editor and regenerates plot.

%   Author(s): P. Gahinet 
%   Revised:   N.Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.37 $  $Date: 2002/06/11 17:29:37 $

if strcmp(Editor.EditMode,'off') | strcmp(Editor.Visible,'off')
   % Editor is inactive
   return
end
ClosedLoopOn = strcmp(Editor.ClosedLoopVisible,'on');

% Model data
LoopData = Editor.LoopData;
Ts = LoopData.Ts;  % sample time

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update Frequency Response Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get normalized filter model (for filter gain mag=1)
NormFilter = zpk(Editor.EditedObject,'norm');
GainF = getzpkgain(Editor.EditedObject,'mag');
switch LoopData.Configuration  
case {1,2}
   GainCL = GainF;
case {3,4}
   GainCL = 1;
end

% Check that loop can be closed (watch for singular loops)
lwarn = lastwarn;warn = warning('off');
if ClosedLoopOn
   % Get closed-loop map r -> y
   Tcl = getclosedloop(LoopData);
   ClosedLoopDef = (isfinite(Tcl));
end

% Compute Bode plot data for F (units = rad/sec,abs,degrees)
[Editor.Magnitude,Editor.Phase,Editor.Frequency,FocusF,SoftFocusF] = ...
   bode(Editor,{NormFilter});

% Get frequency grid(s)
if ClosedLoopOn & ClosedLoopDef
   % Normalized closed-loop model (for filter gain mag=1)
   NormClosedLoop = zpk(Tcl(1,1));
   ResponseID = xlate('Closed-loop response from command r to output y.');
   % Compute closed-loop Bode response for adequate freq. grid
   [Editor.ClosedLoopMagnitude,Editor.ClosedLoopPhase,Editor.ClosedLoopFrequency,...
         FocusCL,SoftFocusCL] = bode(Editor,{NormClosedLoop});
   FreqFocus = mrgfocus({FocusF;FocusCL},[SoftFocusF;SoftFocusCL]);
   MagDataCL = unitconv(GainCL * Editor.ClosedLoopMagnitude,...
      'abs',Editor.Axes.YUnits{1});
else
   ResponseID = '';
   Editor.ClosedLoopFrequency = NaN;
   Editor.ClosedLoopMagnitude = NaN;
   Editor.ClosedLoopPhase = NaN;
   FreqFocus = FocusF;
   MagDataCL = NaN;
end
warning(warn);lastwarn(lwarn);

% Conversion factors
FreqConvert = unitconv(1,'rad/sec',Editor.Axes.XUnits);
PhConvert = unitconv(1,'deg',Editor.Axes.YUnits{2});
MagDataF = unitconv(GainF * Editor.Magnitude,'abs',Editor.Axes.YUnits{1});
if Ts
   NyqFreq = FreqConvert * pi/Ts;
else 
   NyqFreq = NaN;
end

% Resolve undetermined focus (quasi-integrator)
if isempty(FreqFocus)
   if Ts
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
XFocus = getfocus(Editor);  % rounded focus

% Clear HG objects managed by Bode editor
clear(Editor)

% Plot the closed-loop Bode response
HG.BodePlot = [];
if ClosedLoopOn
   FreqData = FreqConvert * Editor.ClosedLoopFrequency;
   PhaseDataCL = PhConvert * Editor.ClosedLoopPhase;
   Zdata = Editor.zlevel('curve',[length(FreqData) 1]);
   HG.BodePlot(1,2) = line(FreqData,MagDataCL,Zdata,...
      'Parent',PlotAxes(1),'Visible',Editor.MagVisible, ...
      'XlimInclude','off',...
      'YlimInclude','off',...
      'Color',Style.Color.ClosedLoop,...
      'UIContextMenu',UIC,...
      'Tag',ResponseID,...
      'ButtonDownFcn',{@LocalRedirectBD Editor},...
      'HelpTopicKey','cloopmagnitudeplot');  
   HG.BodePlot(2,2) = line(FreqData,PhaseDataCL,Zdata,...
      'Parent',PlotAxes(2),'Visible',Editor.PhaseVisible, ...
      'XlimInclude','off',...
      'YlimInclude','off',...
      'Color',Style.Color.ClosedLoop,...
      'HelpTopicKey','cloopphaseplot',...
      'Tag',ResponseID,...
      'ButtonDownFcn',{@LocalRedirectBD Editor},...
      'UIContextMenu',UIC); 
   
   % Update portion of Bode plot to be included in limit picking
   % REVISIT: Simply set BodePlot's XlimIncludeData property when available
   InFocusCL = find(Editor.ClosedLoopFrequency >= XFocus(1) & ...
      Editor.ClosedLoopFrequency <= XFocus(2));
   set(HG.BodeShadow(1,2),'XData',FreqData(InFocusCL),...
      'YData',MagDataCL(InFocusCL),'ZData',zeros(size(InFocusCL)))
   set(HG.BodeShadow(2,2),'XData',FreqData(InFocusCL),...
      'YData',PhaseDataCL(InFocusCL),'ZData',zeros(size(InFocusCL)))
end

% Plot the Bode response of F
FreqData = FreqConvert * Editor.Frequency;
PhaseDataF = PhConvert * Editor.Phase;
Zdata = Editor.zlevel('curve',[length(FreqData) 1]);
FilterID = Editor.LoopData.describe('F','compact');
HG.BodePlot(1,1) = line(FreqData,MagDataF,Zdata,...
   'Parent',PlotAxes(1),'Visible',Editor.MagVisible, ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Color',Style.Color.PreFilter,...
   'UIContextMenu',UIC,...
   'HelpTopicKey','filtermagnitudeplot',...
   'Tag',sprintf('%s magnitude plot',FilterID),...
   'ButtonDownFcn',{@LocalMoveGain Editor 'init'});  
HG.BodePlot(2,1) = line(FreqData,PhaseDataF,Zdata,...
   'Parent',PlotAxes(2),'Visible',Editor.PhaseVisible, ...
   'XlimInclude','off',...
   'YlimInclude','off',...
   'Color',Style.Color.PreFilter,...
   'HelpTopicKey','filterphaseplot',...
   'Tag',sprintf('%s phase plot',FilterID),...
   'ButtonDownFcn',{@LocalRedirectBD Editor},...
   'UIContextMenu',UIC); 

% Update portion of Bode plot to be included in limit picking
% REVISIT: Simply set BodePlot's XlimIncludeData property when available
InFocusF = find(Editor.Frequency >= XFocus(1) & Editor.Frequency <= XFocus(2));
set(HG.BodeShadow(1,1),...
   'XData',FreqData(InFocusF),'YData',MagDataF(InFocusF),'ZData',zeros(size(InFocusF)))
set(HG.BodeShadow(2,1),...
   'XData',FreqData(InFocusF),'YData',PhaseDataF(InFocusF),'ZData',zeros(size(InFocusF)))

% Update HG database
Editor.HG = HG;

% Adjust X position of Nyquist lines
Editor.setnyqline(NyqFreq)

% Plot the compensator poles and zeros
plotcomp(Editor)

% Set Y coordinates of poles/zeros to attach them to Bode curves
Editor.interpy(MagDataF,PhaseDataF);

% Update axis limits
% RE: Includes line handle restacking for proper layering
updateview(Editor)


%-------------------------Callback Functions-------------------------

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


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalRedirectBD %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalRedirectBD(hSrc,event,Editor)
% REVISIT: Delete when events can be blocked at axes level
if ~strcmp(Editor.EditMode,'idle')
   % Redirect to editor axes
   Editor.mouseevent('bd',get(hSrc,'parent'));
end

